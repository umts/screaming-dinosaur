// TODO: Move to eslint.config.js when on eslint 9+.
module.exports = {
  ignorePatterns: [
    'app/assets/builds/*',
    'coverage/*',
    'node_modules/*',
    'public/assets/*',
  ],
  env: {
    browser: true,
    es6: true,
    jquery: true,
  },
  parserOptions: {
    sourceType: 'module',
  },
  globals: {
    'bootstrap': 'readonly',
    'FullCalendar': 'readonly',
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'max-len': ['error', {code: 120}],
  },
  overrides: [{files: ['*.config.js', '.*rc.js'], env: {node: true}}],
};
