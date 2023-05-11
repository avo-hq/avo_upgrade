desc "Upgrades Avo from 2.x to 3.0"
task "avo:upgrade:2_to_3" do
  AvoUpgrade::Upgrade29to30.run
end
