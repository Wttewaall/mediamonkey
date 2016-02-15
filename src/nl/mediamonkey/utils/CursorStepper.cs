using System.Collections.Generic;

public class CursorStepper {

	public enum Mode {
		LINEAR = 0,
		PING_PONG = 1,
		LOOP = 2
	}

	// ---- properties ----

	public Mode mode;
	public int startPosition;
	public int cursor;
	public int length;
	public bool forward;

	// ---- constructor ----

	public CursorStepper(int length, Mode mode) {
		this.length = length;
		this.mode = mode;

		startPosition = 0;
		cursor = startPosition;
		forward = true;
	}

	// ---- public methods ----

	public int Next() {
		return Step(1);
	}

	public int Prev() {
		return Step(-1);
	}

	// ---- protected methods ----

	protected int Step(int value = 1) {
		switch (mode) {

			case Mode.LINEAR: {
				if ((forward && cursor + value <= length - value) || (!forward && cursor - value >= 0)) {
					cursor += forward ? value : -value;
				}
				break;
			}

			case Mode.LOOP: {
				if (forward && cursor + value >= length) cursor = 0;
				else if (!forward && cursor - value < 0) cursor = length - value;
				else cursor += forward ? value : -value;
				break;
			}

			case Mode.PING_PONG: {
				if ((forward && cursor + value >= length) || (!forward && cursor - value < 0)) {
					forward = !forward;
				}
				cursor += forward ? value : -value;
				break;
			}
		}

		return cursor;
	}

}