module.exports = {
  ignoreFiles: [
    'app/assets/builds/*',
    'coverage/**/*',
    'node_modules/**/*',
    'public/assets/**/*',
  ],
  extends: 'stylelint-config-standard',
  overrides: [{
    files: ['**/*.scss'],
    extends: 'stylelint-config-standard-scss',
  }, {
    files: ['app/assets/stylesheets/active_admin.css'],
    rules: {
      'at-rule-no-unknown': [true, {ignoreAtRules: ['config']}],
      'import-notation': 'string',
    },
  }],
};
