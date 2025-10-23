import "reflect-metadata";
import { DataSource } from "typeorm";
import "dotenv/config";
import { User } from "./entities/user.entity.js";
import { Msg } from "./entities/msg.entity.js";

export const AppDataSource = new DataSource({
  type: "postgres",
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "3000"),
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  synchronize: process.env.NODE_ENV === "development",
  logging: false,
  entities: [User, Msg],
  migrations: [],
  subscribers: [],
});
