module MachinesHelper
  def get_machine_types
    MachineType.find(:all).collect {|mt| [mt.name,mt.id]}
  end
end
