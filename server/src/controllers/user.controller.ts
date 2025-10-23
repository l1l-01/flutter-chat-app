import { Request, Response } from "express";
import { User } from "../entities/user.entity.js";
import { Msg } from "../entities/msg.entity.js";
import { AppDataSource } from "../data-source.js";

const userRepository = AppDataSource.getRepository(User);
const msgRepository = AppDataSource.getRepository(Msg);

const findById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id);

    const user = await userRepository.findOneBy({ id });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({ success: true, data: user });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const register = async (req: Request, res: Response) => {
  try {
    const { username } = req.body;

    const usersExists = await userRepository.findOne({ where: { username } });

    if (usersExists) {
      return res.status(400).json({
        success: false,
        message: "Username already exists",
      });
    }

    const user = userRepository.create({ username });
    await userRepository.save(user);

    res.status(201).json({ success: true, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const deregister = async (req: Request, res: Response) => {
  const id = req.params.id;
  const user = await userRepository.findOne({ where: { id: parseInt(id) } });

  if (!user) {
    return res.status(404).json({
      success: false,
      message: "User not found",
    });
  }

  // Remove messages
  const msgs = await msgRepository.find({
    where: { user: { id: user.id } },
  });
  if (msgs.length > 0) {
    await msgRepository.remove(msgs);
  }

  // Remove user
  await userRepository.remove(user);

  return res.status(200).json({
    success: true,
    message: "Your account was removed",
  });
};

const removeAfterOneDay = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const user = await userRepository.findOne({ where: { id: parseInt(id) } });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const expDate = getNextDate(user.createdDate);

    if (new Date() >= expDate) {
      // Remove messages
      const msgs = await msgRepository.find({
        where: { user: { id: user.id } },
      });
      if (msgs.length > 0) {
        await msgRepository.remove(msgs);
      }

      // Remove user
      await userRepository.remove(user);

      return res.status(200).json({
        success: true,
        message: "Your account was removed after 24 hours",
      });
    }

    return res.status(400).json({
      success: false,
      message: "Account cannot be removed yet. Less than 24h since creation.",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

function getNextDate(inputDate: Date) {
  const date = new Date(inputDate);
  // Add 1 day to the date
  const nextDate = new Date(date.setDate(date.getDate() + 1));
  return nextDate;
}

const getAll = async (req: Request, res: Response) => {
  const users = await userRepository.find();
  return res.status(200).json({ success: true, data: users });
};

export default {
  register,
  findById,
  removeAfterOneDay,
  getAll,
  deregister,
};
