module.exports = {
  ignoreFiles: [
    'coverage/**/*',
    'node_modules/**/*',
    'public/assets/**/*',
  ],
  extends: 'stylelint-config-standard',
  overrides: [{
    files: ['**/*.scss'],
    extends: 'stylelint-config-standard-scss',
  }],
};
