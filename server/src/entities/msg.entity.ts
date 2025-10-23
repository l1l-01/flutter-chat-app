import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
} from "typeorm";
import { User } from "./user.entity.js";

@Entity()
export class Msg {
  @PrimaryGeneratedColumn()
  id!: number;

  // many messages → one user
  @ManyToOne(() => User, (user) => user.msgs)
  user!: Object; // breaks metadata cycle

  @Column({ length: 150 })
  content!: string;

  @CreateDateColumn()
  created_at!: Date;
}
