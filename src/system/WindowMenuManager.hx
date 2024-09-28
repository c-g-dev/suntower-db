package system;

import platform.MenuItemType;
import platform.MenuItem;
import platform.Menu;

using ludi.commons.extensions.All;

typedef TransientWindowMenuState = {
    var menuPath: Array<String>;
    var isDisplayed: Bool;
    function shouldApply(model: Model): Bool;
    function createMenuItem(model: Model): MenuItem;
}

typedef MenuTreeNode = {
    var nodeName: String;
    var isRoot: Bool;
    var menuItem: MenuItem;
    var submenu: Menu;
    var children: Array<MenuTreeNode>;
}

class WindowMenuManager {
    static var transientWindowMenuStates: Array<TransientWindowMenuState> = [];
    static var ROOT_WINDOW_MENU: MenuTreeNode;


    public static function addTransientMenu(state: TransientWindowMenuState): Void {
        transientWindowMenuStates.push(state);
    }
    
    public static function addStaticMenu(menuPath: Array<String>, menuItem: MenuItem): Void {
        var currentMenu: MenuTreeNode = ROOT_WINDOW_MENU;
        for (segment in menuPath) {
            var child = currentMenu.children.find(function(node) return node.nodeName == segment);
            if (child == null) {
                var newMenuItem = new MenuItem({ label: segment });
                var submenu = new Menu();
                newMenuItem.submenu = submenu;
                child = { nodeName: segment, isRoot: false, menuItem: newMenuItem, submenu: submenu, children: [] };
                currentMenu.children.push(child);
                currentMenu.submenu.append(newMenuItem);
            }
            currentMenu = child;
        }
        currentMenu.submenu.append(menuItem);
        currentMenu.children.push(nodeFromMenuItem(menuItem));
    }

    public static function setRoot(menu: Menu): Void {
        ROOT_WINDOW_MENU = {
            nodeName: null,
            isRoot: true,
            menuItem: null,
            submenu: menu,
            children: []
        };
    
        for (item in menu.items) {
            ROOT_WINDOW_MENU.children.push(nodeFromMenuItem(item));
        }
    }

    public static function nodeFromMenuItem(menuItem: MenuItem): MenuTreeNode {
        var children: Array<MenuTreeNode> = [];
        
        if (menuItem.submenu != null) {
            for (item in menuItem.submenu.items) {
                children.push(nodeFromMenuItem(item));
            }
        }
    
        return {
            nodeName: menuItem.label,
            isRoot: false,
            menuItem: menuItem,
            submenu: menuItem.submenu,
            children: children
        };
    }
    
    public static function rerenderWindowMenu(model: Model): Void {
        for (state in transientWindowMenuStates) {
            if (state.shouldApply(model)) {
                if (!state.isDisplayed) {
                    applyTransientMenu(model, state);
                    state.isDisplayed = true;
                }
            } else {
                if (state.isDisplayed) {
                    removeTransientMenu(state);
                    state.isDisplayed = false;
                }
            }
        }
    }

    static function applyTransientMenu(model: Model, state: TransientWindowMenuState): Void {
        var currentMenu: MenuTreeNode = ROOT_WINDOW_MENU;

        for (segment in state.menuPath) {
            var child = currentMenu.children.find(function(node) return node.nodeName == segment);
            if (child == null) {
                var menuItem = new MenuItem({ label: segment });
                var submenu = new Menu();
                child = { nodeName: segment, isRoot: false, menuItem: menuItem, submenu: submenu, children: [] };
                currentMenu.children.push(child);
                currentMenu.submenu.append(menuItem);
            }
            currentMenu = child;
        }

        var newItem = state.createMenuItem(model);
        currentMenu.submenu.append(newItem);
    }

    static function removeTransientMenu(state: TransientWindowMenuState): Void {
        var currentMenu: MenuTreeNode = ROOT_WINDOW_MENU;
        var parentMenu: MenuTreeNode = null;
        
        for (segment in state.menuPath) {
            parentMenu = currentMenu;
            var child = currentMenu.children.find(function(node) return node.nodeName == segment);
            if (child == null) {
                return; // The menu doesn't exist
            }
            currentMenu = child;
        }
        
        if (parentMenu != null) {
            parentMenu.submenu.remove(currentMenu.menuItem);
            parentMenu.children.remove(currentMenu);
        }
    }

}