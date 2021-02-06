"use strict";

import cheerio from "cheerio";
import fetch from "node-fetch";
import fs from "fs";
import phantom from "phantom";

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

// TODO: Add sample HTML data
function extractMoves(html) {
  const $ = cheerio.load(html);
  const movesTable = $("table#movecontent tbody tr");
  let moves = [];
  movesTable.each((i, e) => {
    const link = $(e).children("td").find("a");
    const move = link.text();
    if (move) {
      moves.push(move);
    }
  });
  return moves;
}

function extractGameInfo(html) {
  const $ = cheerio.load(html);
  const gameInfoRows = $("div#movetipsdiv tbody");
  console.log(gameInfoRows);
  let gameInfo = {};
  gameInfoRows.each((i, e) => {
    const cells = $(e).children("td");
    const key = cells.eq(0).text();
    const value = cells.eq(1).text();

    if (key && value) {
      gameInfo[key] = value;
    }
  });

  return gameInfo;
}

function extractLinks($) {
  let gameLinks = [];
  $("table#bpwPlayergame tbody tr").each((i, e) => {
    const gameLink = $(e).children("td").eq(4).find("a").attr("href");

    if (gameLink) {
      gameLinks.push(gameLink);
    }
  });
  return gameLinks;
}

async function* downloadGameData(openings) {
  for (const { link } of openings) {
    const response = await fetch(`${BASE_URL}/${link}`);
    const $ = cheerio.load(await response.text());
    const pagination = $("table#bpwPlayergame").siblings().eq(0);

    const gameLinks = extractLinks($);
    yield { pageNum: 1, gameLinks };

    if (pagination.text()) {
      const matches = pagination.text().match(/\d+/g);
      const numPages = matches[matches.length - 1];

      for (const i = 2; i <= numPages; i++) {
        const response = await fetch(`${BASE_URL}/${link}&page=${i}`);
        const html = await response.text();
        const $ = cheerio.load(html);

        const gameLinks = extractLinks($);
        yield { pageNum: i, gameLinks };
      }
    }
  }
}

async function main() {
  const data = await loadOpeningsPage();
  const openings = extractOpenings(data);
  for await (const { pageNum, gameLinks } of downloadGameData(openings)) {
    for (const gameLink of gameLinks) {
      const instance = await phantom.create();
      const page = await instance.createPage();

      const status = await page.open(gameLink);
      const html = await page.property("content");
      instance.exit();

      const moves = extractMoves(html);
      const gameInfo = extractGameInfo(html);
      const idMatches = gameLink.match(/[A-Z0-9]+/gi);
      const id = idMatches[idMatches.length - 1];

      await fs.promises.writeFile(
        `./data/game-${id}.json`,
        JSON.stringify({ ...gameInfo, moves })
      );
    }
  }

  fs.writeFileSync("./data/openings.json", JSON.stringify(openings));
}

if (require.main === module) {
  main();
}
