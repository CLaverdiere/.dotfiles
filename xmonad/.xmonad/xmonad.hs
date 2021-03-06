-- Chris Laverdiere's XMonad config file.
-- Heavily adapted from the example one.

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Constants ----------------------------------------------------------
myTerminal           = "urxvt -uc -bc"  -- Blink and underline cursor.
myBorderWidth        = 2
myModMask            = mod4Mask
myFocusFollowsMouse  = True
myWorkspaces         = ["main", "web", "chat", "dev", "misc", "extra"]
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"


-- Startup Hook -------------------------------------------------------
myStartupHook = spawn "xset r rate 225 30"   -- Set key repeat rate.


-- Key bindings -------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ 

    [

    -- Application keybindings --------------------------------------
      ((modm, xK_y),  spawn "luakit")


    -- Core keybindings ---------------------------------------------

    , ((modm,  xK_Return), spawn $ XMonad.terminal conf)                    -- launch a terminal
    , ((modm, xK_r ), spawn "dmenu_run")                                    -- launch dmenu
    , ((modm .|. shiftMask, xK_c     ), kill)                               -- close focused window
    , ((modm,               xK_space ), sendMessage NextLayout)             -- Rotate through the available layout algorithms
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf) -- Reset the layouts on the current workspace to default
    , ((modm,               xK_n     ), refresh)                            -- Resize viewed windows to the correct size
    , ((modm,               xK_Tab   ), windows W.focusDown)                -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)                -- Move focus to the next window
    , ((modm,               xK_k     ), windows W.focusUp  )                -- Move focus to the previous window
    , ((modm,               xK_m     ), windows W.focusMaster  )            -- Move focus to the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)               -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )               -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )               -- Swap the focused window with the previous window
    , ((modm,               xK_h     ), sendMessage Shrink)                 -- Shrink the master area
    , ((modm,               xK_l     ), sendMessage Expand)                 -- Expand the master area
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)     -- Push window back into tiling
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))         -- Increment the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))      -- Deincrement the number of windows in the master area
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))          -- Quit xmonad
    , ((modm              , xK_q     ), spawn "xmonad -- recompile; xmonad -- restart")  -- Restart xmonad
    ]

    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


-- Mouse bindings ------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


-- Layouts -----------------------------------------------------------
myLayoutHook = spacing 12 $ smartBorders $ tiled ||| Mirror tiled ||| Full
  where
     tiled   = Tall nmaster delta ratio -- default tiling algorithm partitions the screen into two panes
     nmaster = 1                        -- The default number of windows in the master pane
     ratio   = 1/2                      -- Default proportion of screen occupied by master pane
     delta   = 3/100                    -- Percent of screen to increment by when resizing panes


-- Window rules ------------------------------------------------------
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore

    , className =? "luakit"         --> doShift "web"
    , className =? "Firefox"        --> doShift "web"
    , className =? "irssi"          --> doShift "chat"
    ]


-- Logs --------------------------------------------------------------
myLogHook = dynamicLog


-- Main method --------------------------------------------------------
main = xmonad =<< xmobar defaults    -- I'll remove this line when I know what the fuck =<< means.


-- Default setup ------------------------------------------------------
defaults = defaultConfig
  {
    -- Defaults
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- Key Bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- Hooks Layouts
    layoutHook         = myLayoutHook,
    manageHook         = myManageHook,
    -- handleEventHook = myHandleEventHook,
    logHook            = myLogHook,
    startupHook        = myStartupHook
  }
