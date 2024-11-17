const pxReg = /\b(\d+(\.\d+)?)px\b/g;
const checkReg = /\/\* postcss-scale-px (.*?) \*\//;

function template(size, designSize, min, max) {
  return `calc(${size} * clamp(${min}, 100vw, ${max}) / ${designSize})`;
}

const plugin = (opts = { designSize: 1920, min: "960px", max: "1920px" }) => {
  return {
    postcssPlugin: "postcss-scale-px",
    Once(root, { result }) {
      let disabledList = [];
      const checked = checkReg.exec(root.source.input.css);
      if (checked) {
        const disabledStr = checked[1];
        if (disabledStr) {
          disabledList = disabledStr.split(",");
        }
      }
      root.walkDecls((decl) => {
        if (disabledList.indexOf(decl.prop) === -1) {
          if (/px/.test(decl.value)) {
            decl.value = decl.value.replace(pxReg, (_, p1) =>
              template(p1, opts.designSize, opts.min, opts.max)
            );
          }
        }
      });
      result.root = root;
    },
  };
};

plugin.postcss = true;

export default plugin;
