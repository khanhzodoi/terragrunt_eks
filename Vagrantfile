Vagrant.configure("2") do |config|

    config.vm.box = "bento/ubuntu-20.04"
    config.vm.boot_timeout = 3600
    config.ssh.insert_key = false
    # Define the number of machines to create
    num_machines = 1

    # Loop to create multiple machines
    (1..num_machines).each do |i|
        config.vm.define "machine#{i}" do |machine|
            machine.vm.provider "virtualbox" do |vb|
                vb.memory = 2048
                vb.cpus = 2
            end

            machine.vm.hostname = "machine#{i}"
            machine.vm.network "private_network", ip: "192.168.55.#{i + 10}"

            # Read the provisioning script from the file provision.sh
            machine.vm.provision "shell", inline: File.read("scripts/bootstrap.sh")
        end
    end # End loop

end
