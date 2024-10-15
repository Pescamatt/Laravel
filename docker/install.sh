#!/bin/bash

checkExit() {
  if [ "$1" = 1 ]; then
    exit
  fi
}

#This 2 function come from https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

 # Check if user has all dependencies, otherwise install
if user_can_sudo; then
  if ! command -v yq &>/dev/null; then
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
  fi
  if ! command -v make &>/dev/null; then
    sudo apt install make
  fi
fi

# Get site URL for replace
SITE_URL=$(whiptail --inputbox "Enter site url (example gadgets-wuerth.loc)" 8 78 gadgets-wuerth.loc --title "Enter site url" 3>&1 1>&2 2>&3)

# Check if user exit
EXIT_STATUS=$?
checkExit "$EXIT_STATUS"

# Get container name for replace
CONTAINER_NAME=$(whiptail --inputbox "Enter container name (example gadgets-shop)" 8 78 gadgets-shop --title "Enter container name" 3>&1 1>&2 2>&3)

# Check if user exit
EXIT_STATUS=$?
checkExit "$EXIT_STATUS"

ARRAY=()
# Get filename for create list of service available
for f in $(find install/stub -regex '.*\.stub' -print0 | sort -z | xargs -r0); do
  FILE=$(basename -- "$f")
  FILENAME="${FILE%%.*}"
  STATUS=OFF

  case $FILENAME in
  "php")
    STATUS=ON
    ;;
  "nginx")
    STATUS=ON
    ;;
  "traefik")
    STATUS=ON
    ;;
  "mariadb")
    STATUS=ON
    ;;
  *)
    STATUS=OFF
    ;;
  esac

  ARRAY+=("${FILENAME^^}" "${FILENAME} docker service" "${STATUS}")
done

read -r -a CHOICES <<<"$(whiptail --title "Docker image to install" \
  --checklist "Which service you need" $(stty size) 15 "${ARRAY[@]}" 3>&1 1>&2 2>&3)"

if [ -z "$CHOICES" ]; then
  exit
fi

# Check if user has select nextjs as service and create varialbe
if [[ ${CHOICES[*]} =~ "NEXTJS" ]]
then
  NGINX_DIR='nextjs'
  CONTAINER_VERSION='nextjs'
  DEPENDS_ON_SERVICE='nextjs'
  CONNECT_TO='nextjs'
  NEED_LINKS=0
elif [[ ${CHOICES[*]} =~ "VITEPRESS" ]]; then
  NGINX_DIR='vitepress'
  CONTAINER_VERSION='vitepress'
  DEPENDS_ON_SERVICE='vitepress'
  CONNECT_TO='vitepress'
  NEED_LINKS=0
else
  NGINX_DIR='php'
  CONTAINER_VERSION='php'
  DEPENDS_ON_SERVICE='php'
  CONNECT_TO='php-74'
  NEED_LINKS=1
fi

if [ $NEED_LINKS -eq 1 ] ; then
  cp ./install/links_php.yml.stub ./links_php.yml
fi

TO_EXCLUDE=(traefik php mariadb nginx)

for CHOICE in "${CHOICES[@]}"; do
  FILENAME_STUB="${CHOICE,,}.yml.stub"
  SERVICE="${CHOICE,,}"

  if [[ ! ${TO_EXCLUDE[*]} =~ ${SERVICE//\"/} ]]; then
    if [ $NEED_LINKS -eq 1 ] ; then
          yq -i '.services.php.links += "'"${SERVICE//\"/}"'"' ./links_php.yml
    fi
  fi
  cp "./install/stub/${FILENAME_STUB//\"/}" "./install/${SERVICE//\"/}.yml"

  sed -i "s/NGINX_DIR/$NGINX_DIR/g;s/CONTAINER_VERSION/$CONTAINER_VERSION/g;s/DEPENDS_ON_SERVICE/$DEPENDS_ON_SERVICE/g;s/CONNECT_TO/$CONNECT_TO/g" "./install/${SERVICE//\"/}.yml"
done

yq eval-all '. as $item ireduce ({}; . * $item )' ./install/*.yml > docker-compose-dev.yml.temp

if [ $NEED_LINKS -eq 1 ]; then
  yq '. *= load("./links_php.yml")' docker-compose-dev.yml.temp > docker-compose-dev.yml
else
  cp docker-compose-dev.yml.temp docker-compose-dev.yml
fi

while IFS= read -r -d '' file; do
  rm -f "$file"
done < <(find install/ -regex '.*\.yml' -print0)
rm -f docker-compose-dev.yml.temp
rm -f links_php.yml

CONTAINER_NAME=$CONTAINER_NAME envsubst <"./install/Makefile.stub" >"./Makefile"
sed -i "s/CONNECT_TO/$CONNECT_TO/g" "./Makefile"

HOSTNAME=$(hostname) envsubst <"./install/docker-php-ext-xdebug.ini.stub" >"./development/php/docker-php-ext-xdebug.ini"

cp ./install/docker-php-upload.ini.stub ./development/php/docker-php-upload.ini

{
  echo "SITE_URL=$SITE_URL"
  echo "CONTAINER_NAME=$CONTAINER_NAME"
  echo "NGINX_HOST=localhost"
} >>.env.docker

cp ./Makefile ../Makefile
cp ./docker-compose-dev.yml ../docker-compose-dev.yml
cp ./.env.docker ../.env.docker

rm -f ./Makefile ./docker-compose-dev.yml ./.env.docker

whiptail --title "Done" --msgbox "All done" 8 78
