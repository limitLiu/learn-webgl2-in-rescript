# Learn WebGL2 in ReScript

## 项目介绍

试试 WebGL2，技术栈为 [ReScript](https://rescript-lang.org) + [Vite](https://vitejs.dev) + [Bun](https://bun.sh) + [Tauri 2.x](https://tauri.app)。

## 注意事项

创建项目名时，不要使用下划线，不然在 rescript.json 内设置开启 namespace 时会导致 LSP 不工作。

## ReScript 语法基础

### 绑定 JaveScript 操作

导出原生 JaveScript 的 alert 函数，或者直接调用全局对象的属性，需要用到 `@val` 装饰器

```rescript
@val external alert: string => unit = "alert"
@val external devicePixelRatio: float = "devicePixelRatio"
```

使用 JaveScript 对象的属性，使用 `@get` 装饰器

```rescript
@get external width: Dom.element => float = "width"
@get external height: Dom.element => float = "height"
```

使用 JavaScript 对象的方法，使用 `@send` 装饰器

```rescript
@send
external getContextWebGL2: (Dom.element, @as("webgl2") _) => t = "getContext"
```
