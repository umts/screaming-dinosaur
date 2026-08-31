import { defineConfig } from "oxlint";

export default defineConfig({
  $schema: "./node_modules/oxlint/configuration_schema.json",
  ignorePatterns: [
    ".bundle/**",
    "app/assets/builds/**",
    "app/javascript/controllers/index.js",
    "public/assets/**",
    "vendor/assets/**",
  ],
  plugins: ["eslint", "unicorn", "oxc", "import", "promise"],
  categories: {
    correctness: "error",
    suspicious: "warn",
    pedantic: "warn",
    perf: "error",
    restriction: "error",
  },
  rules: {
    "import/no-default-export": "off",
    "unicorn/no-array-reduce": "off",
  },
});
