<template>
  <div class="wrapper" ref="wrapper" @dblclick="boxReset">
    <div
      class="box"
      :style="{width: img.width + 'px', height: img.height + 'px'}"
      :data-center="`left: ${center.left}, top: ${center.top}`"
      ref="box">
      <img
        v-show="url"
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
  img {
    width: 100%;
    height: 100%;
  }
  cursor: move;
}
</style>

<script>
import {addWheelListener, removeWheelListener} from 'wheel'
import Dragger from 'draggabilly'

const $tmpImage = new Image()

export default {
  data() {
    const diagramUrl = '../tmp.svg'
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
      diagramUrl,
      url: null,
    }
  },
  methods: {
    boxReset() {
      const $wrapper = this.$refs.wrapper
      if ($wrapper.clientWidth / $wrapper.clientHeight > this.img.whRate) {
        this.boxResize({height: $wrapper.clientHeight})
      } else {
        this.boxResize({width: $wrapper.clientWidth})
      }
      this.boxCenter()
    },
    boxResize({width = null, height = null} = {}) {
      const $box = this.$refs.box
      if (width) {
        this.img.width = width
        this.img.height = width / this.img.whRate
      } else if (height) {
        this.img.height = height
        this.img.width = height * this.img.whRate
      }
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
      const $wrapper = this.$refs.wrapper
      const $box = this.$refs.box
      this.center.left = left
      this.center.top = top
      $box.style.top = (top * $wrapper.clientHeight - this.img.height / 2) + 'px'
      $box.style.left = (left * $wrapper.clientWidth - this.img.width / 2) + 'px'
    },
    bindEvent() {
      const $wrapper = this.$refs.wrapper
      const $box = this.$refs.box
      const dragger = new Dragger($box)
      dragger.on('dragEnd', event => {
        let {top, left} = $box.style
        top = parseFloat(top)
        left = parseFloat(left)
        this.center.left = (this.img.width / 2 + left) / $wrapper.clientWidth
        this.center.top = (this.img.height / 2 + top) / $wrapper.clientHeight
      })
      addWheelListener($wrapper, e => {
        e.preventDefault()
        let {top, left} = this.center
        const width = this.img.width + e.deltaY * 10
        if (width > 100) {
          this.boxResize({width})
          this.boxCenter({top, left})
        }
      })

      $tmpImage.addEventListener('load', () => {
        this.url = $tmpImage.src
        this.img.realWidth = $tmpImage.width
        this.img.realHeight = $tmpImage.height
        const whRate = $tmpImage.width / $tmpImage.height
        if (this.img.whRate !== whRate) {
          this.img.height = this.img.width / whRate
          this.img.whRate = whRate
        }
        $tmpImage.src = null
      })
    },
    reloadImage() {
      $tmpImage.src = this.diagramUrl + '?' + Date.now()
    },
  },
  mounted() {
    setTimeout(() => {
      this.boxReset.call(this)
    }, 300)
    this.bindEvent()
    this.reloadImage()
    setInterval(() => {
      this.reloadImage()
    }, 2000)
  },
}
</script>
