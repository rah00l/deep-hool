module MachinesHelper
  def get_machine_types
    MachineType.find(:all).collect {|mt| [mt.name,mt.id]}
  end

  def get_machine_names
    MachineMaster.find(:all).collect {|mt| [mt.short_name,mt.short_name]}
  end
end
