desc "Upgrades avo from 2.x to 3.0"
task :avo_upgrade_from_2_to_3 do
  Upgrade29to30.run
end
