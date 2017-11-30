---
theme : "solarized"
highlightTheme: "Zenburn"
transition: cube

title      : Citellus
author     : Pablo Iranzo Gómez
mode : selfcontained
---


# [Citellus](https://github.com/zerodayz/citellus):
## Detecting common pitfalls of deployments

<img src="citellus.png" width="20%" border=0>

<small>Presented by: [Pablo Iranzo Gómez](https://iranzo.github.io)</small>

---

## What is Citellus?

- Citellus is a framework populated by community-contributed scripts that automate detecting problems, including configuration issues, conflicts with package versions, and more.

----

## History: how did it was started?

- The tool, started by Robin Černín after a long weekend shift checking one and over again several sosreports for the same data on different hosts.

- It started with some tests + shell wrapper, and was added a python wrapper by Pablo Iranzo to bring in more powerful features.

- After some design discussions with Engineering, a simpler reporting and design of tests was implemented.

---

## What can you do with Citellus?

- Solve issues faster thanks to the information it provides.<!-- .element: class="fragment" -->
- Run against a sosreport or live environment.<!-- .element: class="fragment" -->
- Use the community-provided plugins for detecting actual or potential issues.<!-- .element: class="fragment" -->
- Code new plugins in your language of choice (bash, python, ruby, etc.) to extend functionality.<!-- .element: class="fragment" -->
    - Contribute them upstream for others to benefit.<!-- .element: class="fragment" -->
- Use that information as part of proactive insights about the systems.<!-- .element: class="fragment" -->

---

## Real life examples?
- For example, with Citellus you can detect:
    - Failed keystone token purges.
    - missing parameters in expired ceilometer data, which can lead to filling up your hard drive.
    - unsynced ntp.
    - outdated packages that have known critical issues.
    - etc (69 plugins as of this writting some of them with more than one issue detected)
- Whatever else you can imagine or code 😉

---

## The goal

- Be so damn simple to write new plugins that anyone can do them.<!-- .element: class="fragment" -->
- Allow to write tests in whatever language of choice (bash, python, perl, etc) as long as they conform to some standards.<!-- .element: class="fragment" -->
- Allow anyone to submit new plugins.<!-- .element: class="fragment" -->

---

## How to run in manually?

As easy as it could:

~~~sh
citellus/citellus/citellus.py /folder/containing/sosreport
~~~

---

## Why upstream?

- This is an open source project. All the scripts should be committed upstream and shared (and we are willing to foster this)
    - Project on GitHub: <https://github.com/zerodayz/citellus/>
- We want contributions to happen from anyone.
- We follow an approach similar to other opensource projects: we do use Gerrit for reviewing the code and UT's for validating basic functionality.

---

## How do I contribute?

At the moment, there’s a strong presence on OpenStack plugins as it is where we solve our issues on everyday basis, but allows anything, as long as there are tests written for it.

For example, it will be easy to report on systems registered against RHN instead of CDN  or systems with a specific version of pacemaker known to have lot of issues or check amount of free memory or memory usage from a process.

Read contributing doc at: 

<small><https://github.com/zerodayz/citellus/blob/master/CONTRIBUTING.md></small>

for more details.

---

## How does it work under the hood?

Philosophy is very simple:
- Citellus is just a simple wrapper.<!-- .element: class="fragment" -->
- Allows to specify on sosreport and test folders<!-- .element: class="fragment" -->
- Finds tests available in test folders<!-- .element: class="fragment" -->
- Executes each test against sosreport and reports return status<!-- .element: class="fragment" -->
- Framework written in python (fallback to prior shell version) so features like parsing, parallel execution of tests, etc are available.<!-- .element: class="fragment" -->

---

## What about the plugins?

Tests are even simpler:
- Written in whatever language of choice as long as they can be executed from shell.
- Output messages to ‘stderr’ (>&2)
- When using strings like echo $”string” bash’s builting i18n is used, so it can be providing languages in the language of your choice.

- Returns:
    - `$RC_OKAY` for success
    - `$RC_FAILED` for error
    - `$RC_SKIPPED` for skipped tests
   - Other for unexpected error

----

## What about the plugins? (continuation)

- Would inherit some env vars like root folder for sosreport (empty for live) (`CITELLUS_ROOT`) or if running live (`CITELLUS_LIVE`) that provide required details. No user input should be required.
- Live tests can for example query DB and ones in sosreport check values on logs

----

## Some execution and script examples?

Check [disk usage](<https://github.com/zerodayz/citellus/blob/master/citellus/plugins/system/disk_usage.sh>):

```sh
#!/bin/bash

# Load common functions
[ -f "${CITELLUS_BASE}/common-functions.sh" ] && . "${CITELLUS_BASE}/common-functions.sh"

# description: error if disk usage is greater than $CITELLUS_DISK_MAX_PERCENT
: ${CITELLUS_DISK_MAX_PERCENT=75}

if [[ $CITELLUS_LIVE = 0 ]]; then
    is_required_file "${CITELLUS_ROOT}/df"
    DISK_USE_CMD="cat ${CITELLUS_ROOT}/df"
else
    DISK_USE_CMD="df -P"
fi

result=$($DISK_USE_CMD |awk -vdisk_max_percent=$CITELLUS_DISK_MAX_PERCENT '/^\/dev/ && substr($5, 0, length($5)-1) > disk_max_percent { print $6,$5 }')

if [ -n "$result" ]; then
    echo "${result}" >&2
    exit $RC_FAILED
else
    exit $RC_OKAY
fi
```

---

## Citellus vs other tools

- XSOS
Provides information on ram usage, etc, no analysis, more like a ‘fancy’ sosreport viewer.

---

## Why not sosreports?

- It’s not Citellus or ‘sosreports’, SOS collects data from the system, Citellus, runs tests/plugins against the data collected.
- Sosreport is installed in RHEL base channels, this makes it well spread, but also, slower to get changes.
- Frequently, data about errors or errors to be, is already in sosreports.
- Citellus is based on known issues and easy to extend with new ones, requires faster devel cycle, targeting more a devops or support teams as target audience.

---

## Other resources
Blog post by Pablo:
<small>
- <http://iranzo.github.io/blog/2017/07/26/Citellus-framework-for-detecting-known-issues/>
- <https://iranzo.github.io/blog/2017/07/31/Magui-for-analysis-of-issues-across-several-hosts/>
- <https://iranzo.github.io/blog/2017/08/17/Jenkins-for-running-CI-tests/>

</small>

---

## Ready for deep dive on tests?

- There are more tests for OpenStack at the moment as this is the speciality where it started, but it’s open and able to extend to whatever is needed.

- Each test should take care of checking if it should run or not and output return code and stderr. Wrapper just runs all the tests or specific ones (filtering)

----

## How to start a new plugin (example)
- `mkdir ~/mytests/`
- Write a script in `~/mytests/hosted-engine.sh`
- `chmod +x hosted-engine.sh`

Requirements:
- return code must be $RC_OKAY (ok), $RC_FAILED (failed)  or $RC_SKIPPED (skipped)
- Messages to be printed on stderr are displayed on failed or ‘skipped’ if verbose enabled
- Running against ‘sosreport’, CITELLUS_ROOT contains path to sosreport folder provided.
- CITELLUS_LIVE contains 0 or 1 if running against live

----

## How to start a new plugin (continuation)

~~~sh
if [ “$CITELLUS_LIVE” = “0” ]; then
    grep -q ovirt-hosted-engine-ha $CITELLUS_ROOT/installed-rpms
    returncode=$?
    if [ “x$returncode” == “x0” ]; then
        exit $RC_OKAY
    else
        echo “ovirt-hosted-engine is not installed “ >&2
        exit $RC_FAILED
    fi
else
    echo “Not running on Live system” >&2
    exit $RC_SKIPPED
fi
~~~

----

## How to test your plugin?

Just specify the folder containing the plugins to use:
~~~sh
[piranzo@host mytests]$ /git/citellus/citellus/citellus.py sosreport-20170724-175510/crta02 ~/mytests/
_________ .__  __         .__  .__
\_   ___ \|__|/  |_  ____ |  | |  |  __ __  ______
/    \  \/|  \   __\/ __ \|  | |  | |  |  \/  ___/
\     \___|  ||  | \  ___/|  |_|  |_|  |  /\___ \
 \______  /__||__|  \___  >____/____/____//____  >
        \/              \/                     \/
found #1 tests at /home/remote/piranzo/mytests/
mode: fs snapshot sosreport-20170724-175510/crta02
# /home/remote/piranzo/mytests/ovirt-engine.sh: failed
    “ovirt-hosted-engine is not installed “
~~~

---

## What is Magui
### Introduction
- Citellus works on individual sosreports against a set of tests (all by default), but some problems require checks across several systems.

<small>For example, galera requires to check seqno across all controllers running database.</small>

- What does M.a.g.u.i. Does?  It runs citellus against each sosreport, gathers and groups the data per plugin.

----

## How does it looks like?
It’s delivered in citellus repo and can be executed by specifying sosreports:
~~~sh
[piranzo@host sosreport-20170725-080733]$ magui.py * -i seqno # (filtering for ‘seqno’ plugins.
{'/home/remote/piranzo/citellus/citellus/plugins/openstack/mysql/seqno.sh': {'ctrl0.localdomain': {'err': '08a94e67-bae0-11e6-8239-9a6188749d23:36117633\n',
                                                                                                   'out': '',
                                                                                                   'rc': 0},
                                                                             'ctrl1.localdomain': {'err': '08a94e67-bae0-11e6-8239-9a6188749d23:36117633\n',
                                                                                                   'out': '',
                                                                                                   'rc': 0},
                                                                             'ctrl2.localdomain': {'err': '08a94e67-bae0-11e6-8239-9a6188749d23:36117633\n',
                                                                                                   'out': '',
                                                                                                   'rc': 0}}}
~~~

- On this example, UUID and SEQNO is shown for each controller.

----

## Next steps with Magui

- At the moment it aggregates the data outputted by scripts in citellus, the idea is to write other plugins Magui-specific that process on the data (a test in citellus might be ok, but could mean a failure when analyzed together with other sosreports)
- For example you can compare the seqno in galera database or ntp sync status across several controllers.


---

## Action Items
<small>
- Add more plugins<!-- .element: class="fragment" -->
- Evangelize about the tool so we can work together in solving our common issues on the same framework.<!-- .element: class="fragment" -->
- Get moving fast enough that the tool has continuity, other tools just died by having a ‘solo’ developer working on spare time<!-- .element: class="fragment" -->
- Start implementing some tests in Magui that provide real intelligence (for example we can report now on seqno, but we do not process that with a specific plugin that reports ‘error’ if one differs).<!-- .element: class="fragment" -->

</small>

---

## Are you still there?

THANK YOU FOR ATTENDING!!

For questions, come to #citellus on Freenode or email us:

- <mailto:rcernin@redhat.com>
- <mailto:Pablo.Iranzo@redhat.com>