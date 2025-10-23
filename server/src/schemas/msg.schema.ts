import { z } from "zod";

export const MsgSchema = z.object({
  content: z
    .string()
    .min(1, "Name must be at least 1 characters long")
    .max(150, "Name must be at most 150 characters long"),
  createdDate: z.date().optional(),
});

export type MsgInput = z.infer<typeof MsgSchema>;
