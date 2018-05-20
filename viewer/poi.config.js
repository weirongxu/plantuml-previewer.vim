module.exports = {
  configuareWebpack(config, context) {
    if (context.command === 'build') {
      config.output.publicPath = './'
    }
    return config
  }
}
