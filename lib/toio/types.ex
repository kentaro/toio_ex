defmodule Toio.Types do
  @moduledoc """
  Type definitions for toio library.
  """

  defmodule PositionId do
    @moduledoc "Position ID information from the mat"
    defstruct [:cube_x, :cube_y, :cube_angle, :sensor_x, :sensor_y, :sensor_angle]

    @type t :: %__MODULE__{
            cube_x: non_neg_integer(),
            cube_y: non_neg_integer(),
            cube_angle: non_neg_integer(),
            sensor_x: non_neg_integer(),
            sensor_y: non_neg_integer(),
            sensor_angle: non_neg_integer()
          }
  end

  defmodule StandardId do
    @moduledoc "Standard ID information"
    defstruct [:id, :angle]

    @type t :: %__MODULE__{
            id: non_neg_integer(),
            angle: non_neg_integer()
          }
  end

  defmodule MotorResponse do
    @moduledoc "Response from motor control command"
    defstruct [:request_id, :response_code]

    @type t :: %__MODULE__{
            request_id: non_neg_integer(),
            response_code: atom()
          }

    @response_codes %{
      0x00 => :success,
      0x01 => :timeout,
      0x02 => :id_missed,
      0x03 => :invalid_parameter,
      0x04 => :invalid_state,
      0x05 => :overwritten,
      0x06 => :unsupported
    }

    def decode_response_code(code), do: Map.get(@response_codes, code, :unknown)
  end

  defmodule MotionSensor do
    @moduledoc "Motion sensor data"
    defstruct [:horizontal, :collision, :double_tap, :posture, :shake]

    @type t :: %__MODULE__{
            horizontal: boolean(),
            collision: boolean(),
            double_tap: boolean(),
            posture: atom(),
            shake: non_neg_integer()
          }

    @postures %{
      0x01 => :top_up,
      0x02 => :bottom_up,
      0x03 => :back_up,
      0x04 => :front_up,
      0x05 => :right_up,
      0x06 => :left_up
    }

    def decode_posture(code), do: Map.get(@postures, code, :unknown)
  end

  defmodule MagneticSensor do
    @moduledoc "Magnetic sensor data"
    defstruct [:state, :force_intensity, :force_x, :force_y, :force_z]

    @type t :: %__MODULE__{
            state: atom(),
            force_intensity: non_neg_integer(),
            force_x: integer(),
            force_y: integer(),
            force_z: integer()
          }
  end

  defmodule AttitudeEuler do
    @moduledoc "Attitude angle in Euler format"
    defstruct [:roll, :pitch, :yaw]

    @type t :: %__MODULE__{
            roll: integer(),
            pitch: integer(),
            yaw: integer()
          }
  end

  defmodule AttitudeQuaternion do
    @moduledoc "Attitude angle in Quaternion format"
    defstruct [:w, :x, :y, :z]

    @type t :: %__MODULE__{
            w: float(),
            x: float(),
            y: float(),
            z: float()
          }
  end

  defmodule ButtonState do
    @moduledoc "Button state"
    defstruct [:button_id, :pressed]

    @type t :: %__MODULE__{
            button_id: non_neg_integer(),
            pressed: boolean()
          }
  end

  defmodule BatteryInfo do
    @moduledoc "Battery information"
    defstruct [:percentage]

    @type t :: %__MODULE__{
            percentage: non_neg_integer()
          }
  end
end
