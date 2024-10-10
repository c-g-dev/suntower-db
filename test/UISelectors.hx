package;

class UISelectors {
	  public static var INSERT_LINE_ANCHOR = "#content > table > tr.selected > td > a";

    public static var CREATE_NEW_SHEET_ANCHOR = ".castle#content > a";
    public static var CREATE_NEW_SHEET_POPUP_CONFIRM = "#newsheet #sheet_form > p.buttons > input[type=submit]:nth-child(1)";
    public static var CREATE_NEW_SHEET_POPUP = "#newsheet";
    public static var CREATE_NEW_SHEET_POPUP_SHEET_NAME_INPUT = "#sheet_name";

    public static var ADD_A_COLUMN_ANCHOR = ".castle#content > table > a";

      
      public static var AUTOSAVE_CONFIG_POPUP = "#autosaveconfig";
      public static var AUTOSAVE_CONFIG_ENABLED_CHECKBOX = "#autosaveconfig #enabled";
      public static var AUTOSAVE_CONFIG_FOLDER_INPUT = "#autosaveconfig #folder";
      public static var AUTOSAVE_CONFIG_INTERVAL_INPUT = "#autosaveconfig #interval";
      public static var AUTOSAVE_CONFIG_MAX_BACKUPS_INPUT = "#autosaveconfig #max_backups";
      public static var AUTOSAVE_CONFIG_SAVE_BUTTON = "#autosaveconfig p.buttons > input[value='Save']";
      public static var AUTOSAVE_CONFIG_CANCEL_BUTTON = "#autosaveconfig p.buttons > input[value='Cancel']";
  
      
      public static var NEW_COLUMN_POPUP = "#newcol";
      public static var NEW_COLUMN_NAME_INPUT = "#newcol #col_form input[name='name']";
      public static var NEW_COLUMN_TYPE_SELECT = "#newcol #col_form select[name='type']";
      public static var NEW_COLUMN_POSSIBLE_VALUES_INPUT = "#col_options .values input[name='values']";
      public static var NEW_COLUMN_SHEET_SELECT = "#col_options .sheet select[name='sheet']";
      public static var NEW_COLUMN_DISPLAY_SELECT = "#col_options .disp select[name='display']";
      public static var NEW_COLUMN_LOCALIZABLE_CHECKBOX = "#col_options .localizable input[name='localizable']";
      public static var NEW_COLUMN_CUSTOM_TYPE_SELECT = "#col_options .custom select[name='ctype']";
      public static var NEW_COLUMN_CUSTOM_TYPE_CREATE_LINK = "#col_options .custom a.tcreate";
      public static var NEW_COLUMN_CUSTOM_TYPE_EDIT_LINK = "#col_options .custom a.tedit";
      public static var NEW_COLUMN_REQUIRED_CHECKBOX = "#col_options .opt input[name='req']";
      public static var NEW_COLUMN_CREATE_BUTTON = "#newcol #col_form p.buttons input.create[type='submit']";
      public static var NEW_COLUMN_MODIFY_BUTTON = "#newcol #col_form p.buttons input.edit[type='submit']";
      public static var NEW_COLUMN_CANCEL_BUTTON = "#newcol #col_form p.buttons input[value='Cancel']";
  
      
      public static var RUN_QUERY_POPUP = "#run-query-popup";
      public static var RUN_QUERY_INPUT = "#run-query-popup #query_input";
      public static var RUN_QUERY_RESULT_AREA = "#run-query-popup #result_area";
      public static var RUN_QUERY_BUTTON = "#run-query-popup #run_query_button";
      public static var RUN_QUERY_CLOSE_BUTTON = "#run-query-popup input[value='Close']";
  
      
      public static var SEARCH_INPUT = "#search input[name='search']";
      public static var SEARCH_CLEAR_BUTTON = "#search i.fa-times-circle";
  
      
      public static var ADD_COLUMN_LINK = "#content table a[href^='javascript:_.newColumn']";
  
      
      public static var SHEET_TABS_LIST = "#sheets";
      public static var SHEET_TABS = "#sheets li";
      public static var ACTIVE_SHEET_TAB = "#sheets li.active";
  
      
      public static var FILE_SELECT_INPUT = "#fileSelect";

      // LevelContent and Level selectors
    public static var LEVEL_CONTENT = "#content";
    public static var LEVEL = "#content .level";
    public static var LEVEL_MENU = "#content .level .menu";
    public static var LEVEL_MENU_LAYERS = "#content .level .menu ul.layers";
    public static var LEVEL_MENU_OPTIONS = "#content .level .menu .options";
    public static var LEVEL_MENU_OPTIONS_BUTTON = "#content .level .menu .options input[value='Options']";
    public static var LEVEL_MENU_CLOSE_BUTTON = "#content .level .menu .options input[value='X']";
    public static var LEVEL_MENU_NEW_LAYER_BUTTON = "#content .level .menu .options input[name='newlayer']";
    public static var LEVEL_CURSOR_POSITION = "#content .level .menu .options .cursorPosition";
  
    public static var LEVEL_SUBMENU_LAYER = "#content .level .submenu.layer";
    public static var LEVEL_LAYER_VISIBLE_CHECKBOX = "#content .level .submenu.layer input[name='visible']";
    public static var LEVEL_LAYER_LOCK_CHECKBOX = "#content .level .submenu.layer input[name='lock']";
    public static var LEVEL_LAYER_ALPHA_RANGE = "#content .level .submenu.layer input[name='alpha']";
    public static var LEVEL_LAYER_MODE_SELECT = "#content .level .submenu.layer select[name='mode']";
    public static var LEVEL_LAYER_COLOR_INPUT = "#content .level .submenu.layer input[name='color']";
    public static var LEVEL_LAYER_LOCK_GRID_CHECKBOX = "#content .level .submenu.layer input[name='lockGrid']";
    public static var LEVEL_LAYER_FILE_BUTTON = "#content .level .submenu.layer input[name='file']";
    public static var LEVEL_LAYER_SIZE_INPUT = "#content .level .submenu.layer input[name='size']";
  
    public static var LEVEL_SUBMENU_OPTIONS = "#content .level .submenu.options";
    public static var LEVEL_OPTIONS_TILE_SIZE_INPUT = "#content .level .submenu.options input[name='tileSize']";
    public static var LEVEL_OPTIONS_SCROLL_X_INPUT = "#content .level .submenu.options input[name='sx']";
    public static var LEVEL_OPTIONS_SCROLL_Y_INPUT = "#content .level .submenu.options input[name='sy']";
    public static var LEVEL_OPTIONS_SCROLL_BUTTON = "#content .level .submenu.options input[value='Scroll']";
    public static var LEVEL_OPTIONS_SCALE_VALUE_INPUT = "#content .level .submenu.options input[name='scale']";
    public static var LEVEL_OPTIONS_SCALE_BUTTON = "#content .level .submenu.options input[value='Scale']";
    public static var LEVEL_OPTIONS_CANCEL_BUTTON = "#content .level .submenu.options input[value='Cancel']";
  
    public static var LEVEL_SUBMENU_NEW_LAYER = "#content .level .submenu.newlayer";
    public static var LEVEL_NEW_LAYER_NAME_INPUT = "#content .level .submenu.newlayer input[name='newName']";
    public static var LEVEL_NEW_LAYER_CREATE_BUTTON = "#content .level .submenu.newlayer input[value='Create']";
    public static var LEVEL_NEW_LAYER_CANCEL_BUTTON = "#content .level .submenu.newlayer input[value='Cancel']";
  
    public static var LEVEL_LAYER_DISPLAY = "#content .level #layerDisplay";
    public static var LEVEL_SCROLL = "#content .level #layerDisplay .scroll.split_0";
    public static var LEVEL_SCROLL_CONTENT = "#content .level #layerDisplay .scroll.split_0 .scrollContent";
    public static var LEVEL_CURSOR = "#content .level #layerDisplay .scroll.split_0 .scrollContent #cursor";
    public static var LEVEL_SIDEBAR = "#content .level #layerDisplay .levelSidebar.split_1";

      
      public static function CELL(x:Int, y:Int) {
          return "#content > table > tr:nth-child(" + (y + 2) +") > td:nth-child(" + (x + 2) + ")";
      }
}