# Demo script, create the recording with 'vhs vhs-demo.tape'
# after first provisioning manually with 'terraform0.13.5 init'
# and 'terraform0.13.5 apply'.
# For more, see https://github.com/charmbracelet/vhs
Output vhs-demo.mp4
# Prevent filling up /tmp
Output frames/

# You have to install these binaries/symlinks
Require bat
Require jq
Require terraform0.13.5

Set Shell "bash"
Set FontSize 22
Set Width 1920
Set Height 1080
Set Framerate 25
Set TypingSpeed 120ms 

# We could also spawn an asciinema shell here to get a text recording as well
Type "# To save time, a server is already provisioned with 'terraform0.13.5 apply'" Sleep 500ms Enter
Type "# It runs with the following Ignition configuration:" Sleep 500ms Enter
Type "bat -P --line-range :32 cl/machine-mynode.yaml.tmpl" Sleep 1s Enter
Sleep 15s
Type "# For a reliable reconfiguration, /etc/config-side-effect should be cleaned up to get recreated by the service," Enter
Type "# while /mydata/data should be kept." Sleep 1s Enter
Type "# We will also preserve the SSH host keys and system logs on reconfigurations:" Sleep 500ms Enter
Type "grep KEEPPATHS azure-vms.tf" Sleep 500ms Enter Sleep 5s Enter
Type "# Each time Terraform sees a userdata change, it will run the following helper:" Sleep 750ms Enter
Type "bat -P --line-range 27:45 reprovision-helper" Sleep 1s Enter
Sleep 15s
Type "# There are two workarounds, one for the Azure userdata endpoint, and an optimization for Terraform" Enter
Type "# to prevent a direct reboot (/.reprovision-marker) after provisioning." Enter
Type "# The essence is to run 'flatcar-reset --keep-machine-id --keep-path REGEX...' and then reboot." Sleep 3s Enter
Type "# Let's prepare a configuration change that triggers the reprovisioning:" Sleep 3s Enter
Type "nano cl/machine-mynode.yaml.tmpl" Sleep 3s Enter Sleep 2s Ctrl+W Sleep 300ms Type "v1" Enter Sleep 300ms Right 2 Backspace 1 Sleep 300ms Type "2" Sleep 1s Ctrl+S Sleep 300ms Ctrl+X Sleep 1s
Type "git diff" Sleep 500ms Enter Sleep 3s
Type "# Check the current values: " Enter
Set TypingSpeed 30ms
Type "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 -p $({ grep ssh_port terraform.tfvars || echo '=22' ; } | cut -s -d = -f 2 | jq -r) core@$(terraform0.13.5 output ip-addresses | cut -s -d = -f 2 | jq -r) head /etc/config-side-effect /mydata/data" Enter Sleep 5s
Set TypingSpeed 120ms
Type "terraform0.13.5 apply" Enter Sleep 60s
Type "yes" Enter Sleep 30s
Sleep 30s
Type "# The instance will now reboot, then in the initramfs clean the rootfs except for what we want to keep (/mydata), finally run Ignition again and come up reconfigured" Sleep 500ms Enter
Type "# Check the new values (setting should be v2, but data value should be as before)" Sleep 500ms Enter
Set TypingSpeed 30ms
Type "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 -p $({ grep ssh_port terraform.tfvars || echo '=22' ; } | cut -s -d = -f 2 | jq -r) core@$(terraform0.13.5 output ip-addresses | cut -s -d = -f 2 | jq -r) head /etc/config-side-effect /mydata/data" Enter Sleep 5s
Set TypingSpeed 120ms
Type "# That's the end of the demo" Enter
Sleep 10s
# Undo the done changes for later reruns
Type "git checkout -- cl/machine-mynode.yaml.tmpl" Enter
Type "terraform0.13.5 apply" Enter Sleep 60s
Type "yes" Enter Sleep 30s
Sleep 30s
