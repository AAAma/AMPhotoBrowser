# AMPhotoBrowser

照片浏览器, 仅本地照片(图片)浏览。
- show&dismiss的照片尾巴动画；
- 双击/捏合缩放；
- 下拉关闭。

## 依赖

- [Masonry](https://github.com/SnapKit/Masonry)

## 用法

```obj-c

@AMWeakify(self);
[AMPhotoBrowser showWithImages:images
                      curIndex:curIndex
                     superView:superView
                imageViewAlias:^UIImageView *(NSInteger idx) {
                  @AMStrongify(self);
                  return imageViews[idx];
                }];

```

- images: 照片源；
- curIndex: 第一次展示事所在的index；
- superView: 需要展示在哪个页面上；
- imageViewAlias: 图片替身，show&dismiss时的照片尾巴需要用到，根据idx返回照片对应的UIImageView，不需要时可为nil。
