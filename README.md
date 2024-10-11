<br />
<div align="center">
  <a>
    <img src="image.png" alt="Logo">
  </a>

  <h3 align="center">CastleDB - Suntower Edition</h3>

  <p align="center">
    Plugin-centric reimplementation of CastleDB.
    <br />
    <a href="http:/www.suntowerdb.com"><strong>Now available in the browser!</strong></a>
    <br />
    <br />
  </p>
</div>

CastleDB - Suntower Edition is a reimplementation of the legacy CastleDB static database application, with browser support and an emphasis on plugin architecture. It is designed to retain the focus and simplicity of the original, while allowing selective feature customization to support per-project needs.
<br/>

<div align="center">
  <img src="https://github.com/user-attachments/assets/6e9485e5-19a6-43f8-9f73-842de0d6a619" alt="Centered Image" />
</div>
<br/>
<br/>

## Plugin Example

Adding a "Duplicate" option to the right-click context menu of sheet rows.

```haxe
var menuPlugin = {
    type: "MenuPlugin_RowContext",
    menuPath: [],
    shouldApply: MenuPlugin_Window_ShouldApply.Always,
    appliesToRow: (context) -> {
        return true; // Always apply to rows
    },
    getMenu: (context) -> {
        var duplicateItem = new MenuItem({ label: "Duplicate" });
        duplicateItem.click = () -> {
            context.sheet.copyLine(context.rowIndex);
            context.model.refresh();
            context.model.save();
        };
        return duplicateItem;
    }
};

var export = [menuPlugin];
```

![image](https://github.com/user-attachments/assets/20a0e3e6-21e1-4fe7-b55d-d3f54b6ecfd6)


# Guides
<a href="https://github.com/c-g-dev/suntower-db/wiki/Tutorial-%E2%80%90-Creating-Plugins"><strong>How to write plugins</strong></a>
<a href="https://github.com/c-g-dev/suntower-db/wiki/Custom-Sheet-Views-%E2%80%90-Tutorial"><strong>How to write custom sheet views</strong></a>
