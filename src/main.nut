enum GSCommand {
	countIndustry,
	createNews,
	addGoal,
	removeGoal,
	removeAllGoal
}

class MainClass extends GSController {
	_load_data = null;
	constructor() {}
}

function MainClass::Start() {
	// Initialization
	this.Init();

	// Wait for the game to start
	this.Sleep(1);

	// Welcome human player
	//local HUMAN_COMPANY = 0;
	//GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_HELLO_WORLD, HUMAN_COMPANY), HUMAN_COMPANY);

	while (true) {
		local loop_start_tick = GSController.GetTick();

		this.HandleEvents();
		this.DoTest();

		// Loop with a frequency of five days
		local ticks_used = GSController.GetTick() - loop_start_tick;
		this.Sleep(1 * 74 - ticks_used);
	}
}

function MainClass::Init() {
	if (this._load_data != null) {
		// Copy loaded data from this._load_data to this.*
		// or do whatever with the loaded data
	}
}

function MainClass::HandleEvents() {
	while (GSEventController.IsEventWaiting()) {
		local e = GSEventController.GetNextEvent();
		GSLog.Info("New Event: " + e.GetEventType());
		switch (e.GetEventType()) {
			case GSEvent.ET_ADMIN_PORT:
				local data = GSEventAdminPort.Convert(e).GetObject();
				if (data != null) {
					if (data.cmd != null && data.arg != null) {
						this.ExecuteCommand(data.cmd, data.arg);
					} else {
						GSAdmin.Send({error = "error while parsing data"});
					}
				} else {
					GSAdmin.Send({error = "error while parsing json"});
				}
			break;
		}
	}
}

function MainClass::ExecuteCommand(cmd, arg) {
	try {
		switch (cmd) {
			case GSCommand.countIndustry:
				GSAdmin.Send({data=GSIndustry.GetIndustryCount()});
			break;
			case GSCommand.createNews:
				GSNews.Create(GSNews.NT_GENERAL, arg[0], arg[1]);
			break;
			case GSCommand.addGoal:
				GSAdmin.Send({goalId=GSGoal.New(arg[0], arg[1], arg[2], arg[3])});
			break;
			case GSCommand.removeGoal:
				if (GSGoal.IsValidGoal(goalId)) {
					GSAdmin.Send({goalId=GSGoal.Remove(arg[0])});
				}
			break;
			case GSCommand.removeAllGoal:
				for (local goalId = 0; goalId < 255; goalId += 1) {
					if (GSGoal.IsValidGoal(goalId)) {
						GSGoal.Remove(goalId);
					}
				}
			break;
			default:
				GSAdmin.Send({exception = "Unknown command", cmd = cmd, arg = arg});
			break;
		}
	} catch (exception) {
		GSAdmin.Send({exception = exception, cmd = cmd, arg = arg});
	}
}

function MainClass::Save() {
	//Log.Info("Saving data to savegame", Log.LVL_INFO);
	return { 
		some_data = null,
		some_other_data = null
	};
}

function MainClass::Load(version, tbl)
{
	//Log.Info("Loading data from savegame made with version " + version + " of the game script", Log.LVL_INFO);

	// Store a copy of the table from the save game
	// but do not process the loaded data yet. Wait with that to Init
	// so that OpenTTD doesn't kick us for taking too long to load.
	this._load_data = {}
   	foreach(key, val in tbl) {
		this._load_data.rawset(key, val);
	}	
}

function MainClass::DoTest()
{
}
