import { Request, Response } from "express";
import { Msg } from "../entities/msg.entity.js";
import { User } from "../entities/user.entity.js";
import { AppDataSource } from "../data-source.js";
import { plainToInstance } from "class-transformer";

const userRepository = AppDataSource.getRepository(User);
const msgRepository = AppDataSource.getRepository(Msg);

const create = async (req: Request, res: Response) => {
  try {
    const { content } = req.body;
    const id = parseInt(req.params.id);

    const user = await userRepository.findOneBy({ id });

    if (!user) {
      return res.status(404).json({ success: false, msg: "User not found" });
    }

    const msg = msgRepository.create({ content, user });
    await msgRepository.save(msg);

    const io = req.app.get("io");
    if (io) {
      io.emit("newMsg", msg);
    } else {
      console.log("Socket.io not initialized");
    }

    return res.status(201).json({ success: true, data: msg });
  } catch (error) {
    console.error("Error creating message:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

const getAll = async (req: Request, res: Response) => {
  try {
    const msgs = await msgRepository.find({ relations: ["user"] });

    // Transform entities to plain objects, respecting @Exclude
    const data = plainToInstance(Msg, msgs);

    return res.status(200).json({ success: true, data: msgs });
  } catch (error) {
    console.error("Error getting messages:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

const getLast20Messages = async (req: Request, res: Response) => {
  try {
    const msgs = await msgRepository.find({
      take: 20,
      order: { id: "ASC" },
      relations: ["user"],
    });

    // Transform entities to plain objects, respecting @Exclude
    const data = plainToInstance(Msg, msgs);

    return res.status(200).json({ success: true, data: msgs });
  } catch (error) {
    console.error("Error getting last 20 messages:", error);
    throw new Error("Internal server error");
  }
};

const remove = async (req: Request, res: Response) => {
  try {
    const msgsCount = await msgRepository.count();
    if (msgsCount >= 20) {
      await msgRepository.clear();
      return res
        .status(200)
        .json({ success: true, message: "Messages cleared" });
    }

    return res
      .status(200)
      .json({ success: false, message: "Messages are not cleared" });
  } catch (error) {
    console.error("Error removing messages:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export default {
  create,
  getAll,
  remove,
  getLast20Messages,
};
