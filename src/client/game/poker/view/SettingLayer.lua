--
-- Author: Q
-- Date: 2017-11-3 
--
--设置界面

local gt = cc.exports.gt

local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
--构造
function SettingLayer:ctor(scene)
    --注册触摸事件
    
    gt.log("是这里吗")
    local csbNode =  cc.CSLoader:create("setting/SettingLayer.csb")
                    :addTo(scene)
                    :move(gt.winCenter)




    self._node = csbNode
    local cbtlistener = function (sender,eventType)
        SettingLayer:onSelectedEvent(sender:getTag(),sender,eventType)
    end

    local sp_bg = csbNode:getChildByName("setting_bg")
    self.m_spBg = sp_bg

    --关闭按钮
    local btn = sp_bg:getChildByName("close_btn")
    btn:setTag(SettingLayer.BT_CLOSE)
    btn:addTouchEventListener(function (ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            scene:PlaySound("zjh/sound_res/cli.mp3")
            csbNode:removeFromParent()
        end
    end)


    local upbtn = csbNode:getChildByName("Image_1")

    upbtn:setVisible(false)
    
    -- if BETA == 0 then 
    --     upbtn:setVisible(true)
    -- else
    --     upbtn:setVisible(false)
    -- end
    
    gt.setOnViewClickedListener(upbtn, function()

        --yl.UploadLog(3)
        csbNode:removeFromParent()
        end)

    --switch
    --音效
    self.m_btnEffect = sp_bg:getChildByName("check_effect")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addEventListener(cbtlistener)
    self.m_btnEffect:setSelected(GlobalUserItem.bSoundAble)

    --音乐
    self.m_btnMusic = sp_bg:getChildByName("check_bg")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addEventListener(cbtlistener)
    self.m_btnMusic:setSelected(GlobalUserItem.bSoundAble_zhj)
end

--
function SettingLayer:showLayer( var )
    self._node:setVisible(var)
end

function SettingLayer:onSelectedEvent( tag, sender )
    
    if SettingLayer.BT_MUSIC == tag then
        -- local music = not GlobalUserItem.bVoiceAble
        -- GlobalUserItem.setVoiceAble(music)
        -- if GlobalUserItem.bVoiceAble == true then
        --     ExternalFun.playBackgroudAudio("background.mp3")
        -- end
        GlobalUserItem.bSoundAble_zhj = not GlobalUserItem.bSoundAble_zhj
        if not GlobalUserItem.bSoundAble_zhj then AudioEngine.stopMusic() end
    elseif SettingLayer.BT_EFFECT == tag then
        local effect = not GlobalUserItem.bSoundAble
        GlobalUserItem.setSoundAble(effect)
    end
end

function SettingLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function SettingLayer:onTouchEnded(touch, event)
    -- local pos = touch:getLocation() 
    -- local m_spBg = self.m_spBg
    -- pos = m_spBg:convertToNodeSpace(pos)
    -- local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    -- if false == cc.rectContainsPoint(rec, pos) then
    --     self:removeFromParent()
    -- end
end

return SettingLayer