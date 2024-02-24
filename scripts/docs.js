import Handlebars from "handlebars"
import { JSDOM } from "jsdom"
import { readFileSync, writeFileSync } from "node:fs"
import * as path from "node:path"
import * as util from "node:util"

const shell = {
  exec: await (async () => util.promisify((await import('node:child_process')).exec))()
}

const controller = new AbortController();

async function sh(cmdAndArgs) {
  if (cmdAndArgs.length === 0 || cmdAndArgs[0].length === 0) throw new Error("Expected a command.")

  const { stdout, stderr } = await shell.exec(cmdAndArgs.join("").split(" ").filter(x => x.length).join(" "), { signal: controller.signal });
  if (stderr && stderr.length) console.error(stderr);
  return stdout?.trim();
}

const files = (await sh`find docs -name '*.html'`).split("\n").map(doc => doc.trim())

const DUB_VERSION = await sh`git describe --tags --abbrev=0`
const MODULES = files.filter(file => {
  const segments = file.split(path.sep).length;
  return segments < 3 && file.includes("docs/index.html") === false
}).map(file => ({
  name: path.basename(file, ".html"),
  file: path.basename(file)
}))
// TODO: Calculate tree of symbols
const SYMBOLS = []
const constants = {
  DUB_VERSION,
  MODULES,
  SYMBOLS,
}

files.forEach(file => {
  const template = Handlebars.compile(readFileSync(file).toString(), { strict: true })
  writeFileSync(file, template(constants))
})
