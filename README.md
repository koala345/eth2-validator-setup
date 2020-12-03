# eth2-validator-setup

This project can be used to spin up an Ethereum 2 validator and monitoring tools on an Ubuntu machine (or Raspberry PI).

It automates installation and configuration of the following:
1. The Prysmatic Labs Ethereum 2.0 client (beacon chain and validator)
2. Geth for running an Eth1 node (optional)
3. Prometheus metrics (optional)
4. Grafana dashboard (optional)
5. Eth2stats integration (optional, recommended for testnet validators)
6. Service scripts for all of the above (services will come up automatically after a crash or system restart)
7. Firewall settings and other configurations

No need to run ANY manual commands on your server, everything is orchestrated remotely.

This project was originally inspired by a great setup guide published by
Somer Esat:
https://medium.com/@SomerEsat/guide-to-staking-on-ethereum-2-0-ubuntu-prysm-witti-2b972e697918

It essentially automates all the steps in this guide, with some minor modifications and enhancements.

It can either build Prysm from source (useful if you want to run a specific branch), or it can
simply download and install the latest binaries.

We will make every attempt to keep this project up to date, so to update your environment in the future you would simply need to do a git pull and run a single script to update your servers.

## Prerequisites

Target machine: Ubuntu 18 or 20. Raspberry PI 4 (with Ubuntu Server 20) should work as well.
For further minimum system requirements please visit this page: https://docs.prylabs.network/docs/install/linux

Local Machine: You will need to have Python and Ansible installed locally.  This can be installed with Pip on Mac/Linux:
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip

If you work on a Windows system it's a bit more involved since Ansible doesn't natively run on Windows. There are several possibilities though:
* Use the Linux subsystem on Windows https://www.youtube.com/watch?v=vE5unuqIauE
* Run Ansible from within Cygwin: https://geekflare.com/ansible-installation-windows/

Before moving on, please confirm that Ansible is installed correctly by opening up a terminal and typing.

```
ansible --version
```

This should report some basic Ansible installation info and its version number.

## Configuration

Once you've set up Python and Ansible locally, it should be a breeze from here. All you need to do it point it at the machine you want to provision, set up a few preferences and you're off to the races.

1. If you are setting up a testnet validator (which is recommended before you attempt to set up a validator for the mainnet), copy the file eth2_testnet.example.yml to eth2_testnet.yml.
Edit the eth2_testnet.yml file and review and update the configuration in there as necessary.

If you are setting up a mainnet validator, copy the file eth2_mainnet.example.yml to eth2_mainnet.yml
and review and update its configuration as necessary.

Note that you can't run both a testnet and mainnet validator on the same machine using this setup tool!

2. Follow the instructions on https://launchpad.ethereum.org/overview to generate your deposit keys.

Once you have them generated, copy the keystore json files for your validators into the validator_keys
directory under this project. Ansible will then automatically copy them into the right location later on.
(This directory is added to .gitignore so you can't accidentally check them into Git)
If you're not comfortable with copying them here for any reason, you can always manually scp/ftp them over
later on.

## Run the Ansible provisioning

Run the provisioning on your server with the setup.sh command. To provision your testnet server, use:

```
./setup.sh testnet <hostname> <username>
```

or to deploy to your mainnet server, use
```
./setup.sh mainnet <hostname> <username>
```
username is optional if it's the same as on your local machine.

This script assumes you are using RSA keypair based authentication and that there's an authorized key on your
server for which you have a private key in ~/.ssh/id_rsa
If you use password based logins to your host (not recommended), you can have ansible prompt you for
that password by adding the '-k' in the setup.sh script.

## import the validator accounts into a wallet

After running Ansible for the first time, all tools and services are installed and you are ready
to import your keys into your validator.

If you followed the instructions above, your keystore files should have already been copied into
/opt/eth2/validators on the server. You can also copy them there manually.

Now, on the server run the following commands:
```
# for testnet (substitute 'pyrmont' for other networks if necessary)
/usr/local/bin/validator -- accounts import --keys-dir=/opt/eth2/validators --accept-terms-of-use --pyrmont


# or for mainnet
/usr/local/bin/validator -- accounts import --keys-dir=/opt/eth2/validators --accept-terms-of-use
```

when prompted for directory, enter '/opt/eth2/prysm-wallet-v2'
Enter a new password for protecting your new wallet as well.

You can verify the wallet accounts afterwards with the following command
(add '--pyrmont' to the command below when doing this for a testnet setup):
```
/usr/local/bin/validator -- accounts list --wallet-dir=/opt/eth2/prysm-wallet-v2 --accept-terms-of-use
```

Now create the wallet password file and fix file access (as root):
```
sudo su -
echo "<myPassword>" > /opt/eth2/prysm-wallet-v2/.walletpwd
chmod 600 /opt/eth2/prysm-wallet-v2/.walletpwd
chown -R validator:validator /opt/eth2/prysm-wallet-v2
```

where <myPassword> is the password that you entered earlier to protect your wallet.

That's all! You should be ready to run your beaconchain and validator now.

Ansible has created systemd services for all processes, and will automatically restart
services when necessary (ie when Prysm is updated or when the startup parameters have changed).
It also set up all processes to run after a system reboot.

The following services may have been installed on your server, depending on your configuration:

```
geth
beaconchain
validator
prometheus
node_exporter
cryptowat
eth2stats
```

you can check status with
```
systemctl status <servicename>
```
and start a process with
```
systemctl start <servicename>
```
if necessary, or use 'stop' or 'restart' commands as needed.

### Checking log files

Checking log files is easy with journalctl. To tail the logs to your terminal for the beaconchain,
you could use:

```
journalctl -fu beaconchain
```

If you just want to see the last 100 lines or so, you could use:
```
journalctl -u beaconchain -n 100
```

## Problems?

You can often find me in the Prysmatic Labs Discord server:
https://discord.com/channels/476244492043812875/719985056319406182

My username is koala#3886 - feel free to ping me.
