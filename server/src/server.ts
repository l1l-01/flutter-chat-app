import express from "express";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";
import { AppDataSource } from "./data-source.js";

import userRoutes from "./routes/user.routes.js";

const app = express();
// Enable CORS
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "http://localhost:5173",
    methods: ["GET", "POST", "PUT", "DELETE"],
  },
});

app.use("/api", userRoutes);

// Save the socket server
app.set("io", io);

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  // user starts typing
  socket.on("typing", (username) => {
    socket.broadcast.emit("userTyping", { username });
  });

  // user stops typing
  socket.on("stopTyping", (username) => {
    socket.broadcast.emit("userStoppedTyping", { username });
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

// Initialize db and start server
AppDataSource.initialize()
  .then(() => {
    server.listen(PORT, () => {
      console.log(`Server running at http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error("Database connection error:", error);
  });
