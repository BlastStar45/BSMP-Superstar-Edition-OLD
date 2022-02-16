package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var BSMPversion:String = '1.0.0';

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
	var storyPic:FlxSprite;
	var freeplayPic:FlxSprite;
	var modsPic:FlxSprite;
	var awardsPic:FlxSprite;
	var creditsPic:FlxSprite;
	var donatePic:FlxSprite;
	var optionsPic:FlxSprite;
	
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("On the Main Menu", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175*scaleRatio ));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175*scaleRatio ));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, 50);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('selected');
			menuItem.screenCenter(X);
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.6));
			menuItem.updateHitbox();
		}
		
		leftArrow = new FlxSprite(200, 100);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow = new FlxSprite(1065, 100);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);
		add(rightArrow);
		
		storyPic = new FlxSprite(400, 220).loadGraphic(Paths.image('mainmenu/pictures/menu_story_mode'));
		storyPic.scale.x = 0.7;
		storyPic.scale.y = 0.7;
		storyPic.updateHitbox();
		storyPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(storyPic);
		storyPic.visible = false;

		freeplayPic = new FlxSprite(250, 220);
		freeplayPic.frames = Paths.getSparrowAtlas('mainmenu/pictures/menu_freeplay');
		freeplayPic.animation.addByPrefix('idle', " idle", 24, true);
		freeplayPic.animation.play('idle');
		freeplayPic.scale.x = 0.65;
		freeplayPic.scale.y = 0.65;
		freeplayPic.updateHitbox();
		freeplayPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(freeplayPic);
		freeplayPic.visible = false;
		
		modsPic = new FlxSprite(250, 230).loadGraphic(Paths.image('mainmenu/pictures/menu_mods'));
		modsPic.scale.x = 0.5;
		modsPic.scale.y = 0.5;
		modsPic.updateHitbox();
		modsPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(modsPic);
		modsPic.visible = false;
		
		awardsPic = new FlxSprite(400, 205).loadGraphic(Paths.image('mainmenu/pictures/menu_awards'));
		awardsPic.scale.x = 0.65;
		awardsPic.scale.y = 0.65;
		awardsPic.updateHitbox();
		awardsPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(awardsPic);
		awardsPic.visible = false;
		
		creditsPic = new FlxSprite(400, 200).loadGraphic(Paths.image('mainmenu/pictures/menu_credits'));
		creditsPic.scale.x = 0.65;
		creditsPic.scale.y = 0.65;
		creditsPic.updateHitbox();
		creditsPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(creditsPic);
		creditsPic.visible = false;
		
		donatePic = new FlxSprite(320, 150).loadGraphic(Paths.image('mainmenu/pictures/menu_donate'));
		donatePic.scale.x = 0.85;
		donatePic.scale.y = 0.85;
		donatePic.updateHitbox();
		donatePic.antialiasing = ClientPrefs.globalAntialiasing;
		add(donatePic);
		donatePic.visible = false;
		
		optionsPic = new FlxSprite(390, 200).loadGraphic(Paths.image('mainmenu/pictures/menu_options'));
		optionsPic.scale.x = 0.65;
		optionsPic.scale.y = 0.65;
		optionsPic.updateHitbox();
		optionsPic.antialiasing = ClientPrefs.globalAntialiasing;
		add(optionsPic);
		optionsPic.visible = false;
		
		var versionShit:FlxText = new FlxText(12, ClientPrefs.getResolution()[1] - 24, 0, "BSMP Superstar Editon v" + BSMPversion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Funkin", 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, ClientPrefs.getResolution()[1] - 64, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Funkin", 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, ClientPrefs.getResolution()[1] - 44, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Funkin", 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if (optionShit[curSelected] == 'story_mode')
		{
			leftArrow.x = 200;
			rightArrow.x = 1065;
			optionsPic.visible = false;
			storyPic.visible = true;
			freeplayPic.visible = false;
		} else if (optionShit[curSelected] == 'freeplay')
		{
			leftArrow.x = 275;
			rightArrow.x = 980;
			storyPic.visible = false;
			freeplayPic.visible = true;
			modsPic.visible = false;
		} else if (optionShit[curSelected] == 'mods')
		{
			leftArrow.x = 400;
			rightArrow.x = 865;
			freeplayPic.visible = false;
			modsPic.visible = true;
			awardsPic.visible = false;
		} else if (optionShit[curSelected] == 'awards')
		{
			leftArrow.x = 305;
			rightArrow.x = 960;
			modsPic.visible = false;
			awardsPic.visible = true;
			creditsPic.visible = false;
		} else if (optionShit[curSelected] == 'credits')
		{
			leftArrow.x = 275;
			rightArrow.x = 985;
			awardsPic.visible = false;
			creditsPic.visible = true;
			donatePic.visible = false;
		} else if (optionShit[curSelected] == 'donate')
		{
			leftArrow.x = 295;
			rightArrow.x = 975;
			creditsPic.visible = false;
			donatePic.visible = true;
			optionsPic.visible = false;
		} else if (optionShit[curSelected] == 'options')
		{
			leftArrow.x = 285;
			rightArrow.x = 980;
			donatePic.visible = false;
			optionsPic.visible = true;
			storyPic.visible = false;
		}
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				spr.visible = true;
			} else {
				spr.visible = false;
			}
		});

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
			
			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
			
			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('selected');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
