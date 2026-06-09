import express from "express";
import cors from "cors";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (_, res) => {
  res.json({
    status: "healthy",
    service: "api-gateway"
  });
});

app.post("/users", (req, res) => {
  res.json({
    message: "User created",
    data: req.body
  });
});

app.post("/aws-accounts", (req, res) => {
  res.json({
    message: "AWS Account saved",
    data: req.body
  });
});

app.post("/instances", (req, res) => {
  res.json({
    message: "Instance request submitted",
    data: req.body
  });
});

app.post("/ai/recommend", (req, res) => {
  res.json({
    recommendation: {
      instanceType: "t3.medium",
      os: "Ubuntu 22.04",
      storage: "50 GB SSD"
    }
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`API Gateway running on ${PORT}`);
});