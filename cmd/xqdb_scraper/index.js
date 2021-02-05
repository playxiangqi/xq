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
        name: link.text(),
        link: link.attr("href"),
      });
    }
  });
  return openings;
}

function saveOpeningsData(data) {
  fs.writeFileSync("./openings.json", JSON.stringify(data));
}

async function main() {
  const data = await loadOpeningsPage();
  const openings = extractOpenings(data);
  saveOpeningsData(openings);
}

if (require.main === module) {
  main();
}
