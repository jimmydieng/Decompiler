    #!/bin/sh

if [ $# -lt 1 ]; then
  echo "usage: [apk file]"
  exit 0
fi

APKFILE=$1
APKTOOL=`pwd`/apktool-cli.jar
D2J=`pwd`/dex2jar-2.0/d2j-dex2jar.sh
JAD=`pwd`/jad
OUTPUTDIR=`echo $APKFILE | sed 's/\.apk//g'`
TMPDIR=tmp

#
# 1. apk -> AndroidManifest.xml smali res
#
echo java -jar $APKTOOL d $APKFILE $OUTPUTDIR
java -jar $APKTOOL d $OUTPUTDIR $APKFILE

#
# 2. apk -> zip
#
unzip $APKFILE -d $TMPDIR

# 
# 3. classes.jar -> classes/
# 
mkdir $TMPDIR
mkdir $TMPDIR/classes
$D2J $TMPDIR/classes.dex --output $TMPDIR/classes/classes.jar

cd $TMPDIR/classes
jar xvf classes.jar

# 
# 4. classes/ -> src/
# 
classes=`find . -type f -name "*.class"`
for i in $classes; do
    $JAD -s java -d ../src -r $i
done
# $JAD -s java -d ../src -r ./**/*.class
cd -

mv $TMPDIR/src $OUTPUTDIR/

#
# 5. remove tmp dir
# 
rm -rf $TMPDIR

