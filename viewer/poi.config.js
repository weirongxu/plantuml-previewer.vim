module.exports = {
  production: {
    webpack(config) {
      config.output.publicPath = './'
      return config
    }
  }
}
