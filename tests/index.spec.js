import app from "../src/index";
import request from "supertest";
import mongoose from "mongoose";


beforeAll(async () => {
  await mongoose.connect('mongodb://acervantes:password@my_mongo:27017/miapp?authSource=admin', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
});

afterAll(async () => {
  await mongoose.connection.close();
});

describe("GET /encuestados", () => {
  test("should respond with a 200 status code", async () => {
    const res = await request(app).get('/encuestados').send();
    expect(res.statusCode).toBe(200);
  });
});

describe("GET /encuesta", () => {
  test("should respond with a 200 status code", async () => {
    const res = await request(app).get('/encuesta').send();
    expect(res.statusCode).toBe(200);
  });
});
