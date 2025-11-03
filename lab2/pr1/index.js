const express = require("express");
const app = express();
const PORT = 8001;

app.get("/api/hello", (req, res) => {
  res.json({ message: "Приветули!!" });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});
