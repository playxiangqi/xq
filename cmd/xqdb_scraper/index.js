"use strict";

import cheerio from "cheerio";
import fetch from "node-fetch";
import fs, { promises } from "fs";

const BASE_URL = "http://www.01xq.com/xqopening";
const OPENINGS_URL = `${BASE_URL}/xqolist.asp`;

async function loadOpeningsPage() {
  const response = await fetch(OPENINGS_URL);
  return response.text();
}

function extractOpenings(html) {
  const $ = cheerio.load(html);
  const openingsTable = $("table#bpwPlayerGame tbody tr");
  let openings = [];
  openingsTable.each((i, e) => {
    const cells = $(e).children("td");
    const code = cells.eq(1).text();
    const link = cells.eq(2).find("a");

    if (code) {
      openings.push({
        code,
        name: link.text().replace(/[^a-zA-Z ]/g, ""),
        link: link.attr("href"),
      });
    }
  });
  return openings;
}

async function* downloadGameData(openings) {
  for (const { link } of openings) {
    const response = await fetch(`${BASE_URL}/${link}`);
    const html = await response.text();
    const $ = cheerio.load(html);

    yield response.text();
  }
}

function saveOpeningsData(data) {
  fs.writeFileSync("./openings.json", JSON.stringify(data));
}

async function main() {
  const data = await loadOpeningsPage();
  const openings = extractOpenings(data);
  const games = downloadGameData(openings);
  for await (const page of downloadGameData(openings)) {
    console.log(page);
  }
  saveOpeningsData(openings);
}

if (require.main === module) {
  main();
}
