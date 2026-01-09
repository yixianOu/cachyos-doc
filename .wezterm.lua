-- C:\Users\ouyixian\.wezterm.lua

local wezterm = require 'wezterm'

-- 添加配置路径（Windows 路径需要转义）
package.path = package.path .. ';' .. wezterm.home_dir .. '/wezterm-config-master/wezterm-config-master/?.lua'
   .. ';' .. wezterm.home_dir .. '/wezterm-config-master/wezterm-config-master/?/init.lua'

-- 引用下载的配置
local Config = require('config')

require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'numbered_box' })
require('events.new-tab-button').setup()
require('events.gui-startup').setup()

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options