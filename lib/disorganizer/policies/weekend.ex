defmodule Disorganizer.Policies.Weekend do
  # During the weekend/friday night say happy weekend! priority: low, banter
  # During friday say "it's a good time to do some merging!" priority: low, banter
  # During monday say "It's a code freeze day!" low, banter

  # Check for github PR's with one +1
  # Check for old github PR's without WIP ( > 36h )
  def apply() do
  end
end
