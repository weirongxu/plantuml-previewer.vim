<template>
  <div class="wrapper" ref="wrapper" @dblclick="boxReset">
    <div class="box" ref="box">
      <img
        v-show="url"
        :style="{width: img.width, height: img.height}"
        :src="url"
        ref="img"
        @load="() => $emit('loadedImage')">
    </div>
  </div>
</template>

<style lang="scss" scoped>
.wrapper {
  width: 100%;
  height: 100%;
  position: relative;
  top: 0;
  left: 0;
  overflow: hidden;
  background: #ccc;
}
.box {
  position: absolute;
  cursor: move;
}
</style>

<script>
import {addWheelListener, removeWheelListener} from 'wheel'
import url from '!file-loader!./tmp.svg'
import Dragger from 'draggabilly'

export default {
  data() {
    const baseUrl = process.env.NODE_ENV === 'production' ? '../tmp.svg' : url
    return {
      img: {
        realWidth: null,
        realHeight: null,
        width: null,
        height: null,
        whRate: null,
      },
      center: {
        left: null,
        top: null,
      },
      baseUrl,
      url: null,
    }
  },
  methods: {
    boxReset() {
      let $wrapper = this.$refs.wrapper
      if ($wrapper.clientWidth / $wrapper.clientHeight > this.img.whRate) {
        this.boxResize({height: $wrapper.clientHeight})
      } else {
        this.boxResize({width: $wrapper.clientWidth})
      }
      this.boxCenter()
    },
    boxResize({width = null, height = null} = {}) {
      let $box = this.$refs.box
      let $img = this.$refs.img
      if (width) {
        this.img.width = width
        this.img.height = width / this.img.whRate
      } else if (height) {
        this.img.height = height
        this.img.width = height * this.img.whRate
      }
      $img.width = $box.width = this.img.width
      $img.height = $box.height = this.img.height
    },
    boxCenter({top = 0.5, left = 0.5} = {}) {
      if (top < 0) {
        top = 0
      }
      if (top > 1) {
        top = 1
      }
      if (left < 0) {
        left = 0
      }
      if (left > 1) {
        left = 1
      }
      let $wrapper = this.$refs.wrapper
      let $box = this.$refs.box
      this.center.left = left
      this.center.top = top
      $box.style.top = ($wrapper.clientHeight/2 - top*this.img.height) + 'px'
      $box.style.left = ($wrapper.clientWidth/2 - left*this.img.width) + 'px'
    },
    bindEvent() {
      let $wrapper = this.$refs.wrapper
      let $box = this.$refs.box
      var dragger = new Dragger($box)
      dragger.on('dragEnd', event => {
        let {top, left} = $box.style
        top = parseFloat(top)
        left = parseFloat(left)
        this.center.top = ($wrapper.clientHeight/2 - top)/this.img.height
        this.center.left = ($wrapper.clientWidth/2 - left)/this.img.width
      })
      addWheelListener($wrapper, e => {
        e.preventDefault()
        let {top, left} = this.center
        if (e.wheelDelta > 0) {
          this.boxResize({width: this.img.width * 1.1})
          this.boxCenter({top, left})
        } else {
          this.boxResize({width: this.img.width * 0.9})
          this.boxCenter({top, left})
        }
      })
    },
    reloadImage() {
      let url = this.baseUrl + '?' + Date.now()
      let img = new Image()
      img.src = url
      img.addEventListener('load', () => {
        this.url = url
        this.img.realWidth = img.width
        this.img.realHeight = img.height
        let whRate = img.width / img.height
        if (this.img.whRate !== whRate) {
          this.$refs.img.height = this.$refs.img.width / whRate
          this.img.whRate = whRate
        }
      })
    },
  },
  mounted() {
    this.$once('loadedImage', this.boxReset.bind(this))
    if (this.$refs.img.complete) {
      this.$emit('loadedImage')
    }
    this.bindEvent()
    this.reloadImage()
    setInterval(() => {
      this.reloadImage()
    }, 1000)
  },
}
</script>
