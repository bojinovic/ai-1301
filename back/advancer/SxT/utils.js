import * as dotenv from "dotenv";
dotenv.config();

const BEARER_TOKEN = process.env.SXT_BEARER_TOKEN;

const DB_TABLE = process.env.SXT_DB_TABLE;

const BISCUIT = process.env.SXT_BISCUIT;

const INSERT_URL = process.env.SXT_DML_URL;
const QUERY_URL = process.env.SXT_QUERY_URL;

const COLUMN_STRING = "(ID, NAME)";

const headers = {
  Accept: "application/json",
  "Content-type": "application/json",
  Authorization: `Bearer ${BEARER_TOKEN}`,
  authentication: `Bearer ${BEARER_TOKEN}`,
};

const generateValueString = (name) => {
  return `(${Math.floor(Math.random() * 212312333)}, '${name}')`;
};

export const insert = async () => {
  const VALUE_STRING = generateValueString("Milos");

  const data = {
    resourceId: DB_TABLE,
    sqlText: `INSERT INTO ${DB_TABLE} ${COLUMN_STRING} VALUES ${VALUE_STRING}`,
    biscuits: [BISCUIT],
  };

  const response = await fetch(INSERT_URL, {
    method: "POST",
    headers,
    body: JSON.stringify(data),
  });
  return response.json();
};

export const retrieve = async () => {
  const data = {
    resourceId: DB_TABLE,
    sqlText: `SELECT * FROM ${DB_TABLE}`,
    rowCount: 10,
    biscuits: [BISCUIT],
  };

  const response = await fetch(QUERY_URL, {
    method: "POST",
    headers,
    body: JSON.stringify(data),
  });
  return response.json();
};
