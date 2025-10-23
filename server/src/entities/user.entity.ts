import { Exclude } from "class-transformer";
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  CreateDateColumn,
} from "typeorm";
import { Msg } from "./msg.entity.js";

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 20 })
  username!: string;

  @OneToMany(() => Msg, (msg) => msg.user)
  // excludes from JSON
  @Exclude()
  msgs!: Msg[];

  @CreateDateColumn()
  createdDate!: Date;
}
