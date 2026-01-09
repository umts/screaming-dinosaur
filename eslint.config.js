const js = require('@eslint/js');
const googleConfig = require('eslint-config-google');
const globals = require('globals');

module.exports = [
  {
    ignores: [
      '.bundle/*',
      'app/assets/builds/*',
      'app/javascript/controllers/index.js',
      'coverage/*',
      'node_modules/*',
      'public/assets/*',
    ],
  },
  {
    files: ['**/*.js'],
    ...js.configs.recommended,
    ...googleConfig,
    rules: {
      ...js.configs.recommended.rules,
      ...googleConfig.rules,
      'max-len': ['error', {code: 120}],
    },
  },
  {
    files: ['app/javascript/**/*.js'],
    languageOptions: {
      globals: {...globals.browser},
    },
  },
  {
    files: ['contrib/am-eve-split/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        'Runtime': 'readonly',
        'Twilio': 'readonly',
      },
    },
  },
  {
    files: ['*.config.js'],
    languageOptions: {
      globals: {...globals.node},
    },
  },
];
