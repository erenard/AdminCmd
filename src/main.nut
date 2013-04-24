enum GSCommand {
	countIndustry,
	createNews,
	addGoal,
	removeGoal,
	removeAllGoal
}

class MainClass extends GSController {
	constructor() {}
}

function MainClass::Start() {
	// Wait for the game to start
	this.Sleep(1);

	while (true) {
		local loop_start_tick = GSController.GetTick();

		this.HandleEvents();

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
					if (data.c != null && data.a != null) {
						this.ExecuteCommand(data.c, data.a);
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

function MainClass::ExecuteCommand(cmd, args) {
	try {
		switch (cmd) {
			case GSCommand.countIndustry:
				GSAdmin.Send({data=GSIndustry.GetIndustryCount()});
			break;
			case GSCommand.createNews:
				GSNews.Create(args[0], args[1], args[2]);
			break;
			case GSCommand.addGoal:
				GSAdmin.Send({goalId=GSGoal.New(args[0], args[1], args[2], args[3])});
			break;
			case GSCommand.removeGoal:
				if (GSGoal.IsValidGoal(goalId)) {
					GSAdmin.Send({goalId=GSGoal.Remove(args[0])});
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
				GSAdmin.Send({exception = "Unknown command", cmd = cmd, args = args});
			break;
		}
	} catch (exception) {
		GSAdmin.Send({exception = exception, cmd = cmd, args = args});
	}
}
