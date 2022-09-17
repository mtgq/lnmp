#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

echo "+-------------------------------------------+"
echo "|    Manager for LNMP, Written by Licess    |"
echo "+-------------------------------------------+"
echo "|              https://lnmp.org             |"
echo "+-------------------------------------------+"

PHPFPMPIDFILE=/usr/local/php/var/run/php-fpm.pid

arg1=$1
arg2=$2

Add_VHost_Config()
{
    if [ ! -f /usr/local/nginx/conf/rewrite/${rewrite}.conf ]; then
        echo "Create Virtul Host Rewrite file......"
        touch /usr/local/nginx/conf/rewrite/${rewrite}.conf
        echo "Create rewirte file successful,You can add rewrite rule into /usr/local/nginx/conf/rewrite/${rewrite}.conf."
    else
        echo "You select the exist rewrite rule:/usr/local/nginx/conf/rewrite/${rewrite}.conf"
    fi

    cat >"/usr/local/nginx/conf/vhost/${domain}.conf"<<EOF
server
    {
        listen 80;
        #listen [::]:80;
        server_name ${domain} ${moredomain};
        index index.html index.htm index.php default.html default.htm default.php;
        root  ${vhostdir};

        include rewrite/${rewrite}.conf;
        #error_page   404   /404.html;

        # Deny access to PHP files in specific directory
        #location ~ /(wp-content|uploads|wp-includes|images)/.*\.php$ { deny all; }

        ${include_enable_php}

        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
        {
            expires      30d;
        }

        location ~ .*\.(js|css)?$
        {
            expires      12h;
        }

        location ~ /.well-known {
            allow all;
        }

        location ~ /\.
        {
            deny all;
        }

        ${al}
    }
EOF

    echo "Test Nginx configure file......"
    /usr/local/nginx/sbin/nginx -t
    echo "Reload Nginx......"
    /usr/local/nginx/sbin/nginx -s reload
}

Multiple_PHP_Select()
{
    if [[ ! -s /usr/local/php5.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.2.conf ]] && [[ ! -s /usr/local/php5.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.3.conf ]] && [[ ! -s /usr/local/php5.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.4.conf ]] && [[ ! -s /usr/local/php5.5/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.5.conf ]] && [[ ! -s /usr/local/php5.6/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.6.conf ]] && [[ ! -s /usr/local/php7.0/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.0.conf ]] && [[ ! -s /usr/local/php7.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.1.conf ]] && [[ ! -s /usr/local/php7.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.2.conf ]] && [[ ! -s /usr/local/php7.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.3.conf ]] && [[ ! -s /usr/local/php7.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.4.conf ]] && [[ ! -s /usr/local/php8.0/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.0.conf ]] && [[ ! -s /usr/local/php8.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.1.conf ]]; then
        if [ "${enable_pathinfo}" == "y" ]; then
            include_enable_php="include enable-php-pathinfo.conf;"
        else
            include_enable_php="include enable-php.conf;"
        fi
    else
        echo "Multiple PHP version found, Please select the PHP version."
        Cur_PHP_Version="`/usr/local/php/bin/php-config --version`"
        Echo_Green "1: Default Main PHP ${Cur_PHP_Version}"
        if [[ -s /usr/local/php5.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.2.conf && -s /etc/init.d/php-fpm5.2 ]]; then
            Echo_Green "2: PHP 5.2 [found]"
        fi
        if [[ -s /usr/local/php5.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.3.conf && -s /etc/init.d/php-fpm5.3 ]]; then
            Echo_Green "3: PHP 5.3 [found]"
        fi
        if [[ -s /usr/local/php5.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.4.conf && -s /etc/init.d/php-fpm5.4 ]]; then
            Echo_Green "4: PHP 5.4 [found]"
        fi
        if [[ -s /usr/local/php5.5/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.5.conf && -s /etc/init.d/php-fpm5.5 ]]; then
            Echo_Green "5: PHP 5.5 [found]"
        fi
        if [[ -s /usr/local/php5.6/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.6.conf && -s /etc/init.d/php-fpm5.6 ]]; then
            Echo_Green "6: PHP 5.6 [found]"
        fi
        if [[ -s /usr/local/php7.0/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.0.conf && -s /etc/init.d/php-fpm7.0 ]]; then
            Echo_Green "7: PHP 7.0 [found]"
        fi
        if [[ -s /usr/local/php7.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.1.conf && -s /etc/init.d/php-fpm7.1 ]]; then
            Echo_Green "8: PHP 7.1 [found]"
        fi
        if [[ -s /usr/local/php7.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.2.conf && -s /etc/init.d/php-fpm7.2 ]]; then
            Echo_Green "9: PHP 7.2 [found]"
        fi
        if [[ -s /usr/local/php7.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.3.conf && -s /etc/init.d/php-fpm7.3 ]]; then
            Echo_Green "10: PHP 7.3 [found]"
        fi
        if [[ -s /usr/local/php7.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.4.conf && -s /etc/init.d/php-fpm7.4 ]]; then
            Echo_Green "11: PHP 7.4 [found]"
        fi
        if [[ -s /usr/local/php8.0/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.0.conf && -s /etc/init.d/php-fpm8.0 ]]; then
            Echo_Green "12: PHP 8.0 [found]"
        fi
        if [[ -s /usr/local/php8.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.1.conf && -s /etc/init.d/php-fpm8.1 ]]; then
            Echo_Green "13: PHP 8.1 [found]"
        fi
        Echo_Yellow "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 or 13): "
        read php_select
        case "${php_select}" in
            1)
                echo "Current selection: PHP ${Cur_PHP_Version}"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php-pathinfo.conf;"
                else
                    include_enable_php="include enable-php.conf;"
                fi
                ;;
            2)
                echo "Current selection: PHP `/usr/local/php5.2/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php5.2-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php5.2-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php5.2-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi5.2.sock/g' /usr/local/nginx/conf/enable-php5.2-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php5.2.conf;"
                fi
                ;;
            3)
                echo "Current selection: PHP `/usr/local/php5.3/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php5.3-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php5.3-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php5.3-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi5.3.sock/g' /usr/local/nginx/conf/enable-php5.3-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php5.3.conf;"
                fi
                ;;
            4)
                echo "Current selection: PHP `/usr/local/php5.4/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php5.4-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php5.4-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php5.4-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi5.4.sock/g' /usr/local/nginx/conf/enable-php5.4-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php5.4.conf;"
                fi
                ;;
            5)
                echo "Current selection: PHP `/usr/local/php5.5/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php5.5-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php5.5-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php5.5-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi5.5.sock/g' /usr/local/nginx/conf/enable-php5.5-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php5.5.conf;"
                fi
                ;;
            6)
                echo "Current selection: PHP `/usr/local/php5.6/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php5.6-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php5.6-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php5.6-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi5.6.sock/g' /usr/local/nginx/conf/enable-php5.6-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php5.6.conf;"
                fi
                ;;
            7)
                echo "Current selection:: PHP `/usr/local/php7.0/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php7.0-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php7.0-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php7.0-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi7.0.sock/g' /usr/local/nginx/conf/enable-php7.0-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php7.0.conf;"
                fi
                ;;
            8)
                echo "Current selection:: PHP `/usr/local/php7.1/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php7.1-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php7.1-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php7.1-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi7.1.sock/g' /usr/local/nginx/conf/enable-php7.1-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php7.1.conf;"
                fi
                ;;
            9)
                echo "Current selection:: PHP `/usr/local/php7.2/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php7.2-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php7.2-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php7.2-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi7.2.sock/g' /usr/local/nginx/conf/enable-php7.2-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php7.2.conf;"
                fi
                ;;
            10)
                echo "Current selection:: PHP `/usr/local/php7.3/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php7.3-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php7.3-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php7.3-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi7.3.sock/g' /usr/local/nginx/conf/enable-php7.3-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php7.3.conf;"
                fi
                ;;
            11)
                echo "Current selection:: PHP `/usr/local/php7.4/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php7.4-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php7.4-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php7.4-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi7.4.sock/g' /usr/local/nginx/conf/enable-php7.4-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php7.4.conf;"
                fi
                ;;
            12)
                echo "Current selection:: PHP `/usr/local/php8.0/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php8.0-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php8.0-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php8.0-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi8.0.sock/g' /usr/local/nginx/conf/enable-php8.0-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php8.0.conf;"
                fi
                ;;
            13)
                echo "Current selection:: PHP `/usr/local/php8.1/bin/php-config --version`"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php8.1-pathinfo.conf;"
                    if [ ! -s /usr/local/nginx/conf/enable-php8.1-pathinfo.conf ]; then
                        \cp /usr/local/nginx/conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php8.1-pathinfo.conf
                        sed -i 's/php-cgi.sock/php-cgi8.1.sock/g' /usr/local/nginx/conf/enable-php8.1-pathinfo.conf
                    fi
                else
                    include_enable_php="include enable-php8.1.conf;"
                fi
                ;;
            *)
                echo "Default,Current selection: PHP ${Cur_PHP_Version}"
                php_select="1"
                if [ "${enable_pathinfo}" == "y" ]; then
                    include_enable_php="include enable-php-pathinfo.conf;"
                else
                    include_enable_php="include enable-php.conf;"
                fi
                ;;
        esac
    fi
}

Add_VHost()
{
    domain=""
    while :;do
        Echo_Yellow "Please enter domain(example: www.lnmp.org): "
        read domain
        if [ "${domain}" != "" ]; then
            if [ -f "/usr/local/nginx/conf/vhost/${domain}.conf" ]; then
                Echo_Red " ${domain} is exist,please check!"
                exit 1
            else
                echo " Your domain: ${domain}"
            fi
            break
        else
            Echo_Red "Domain name can't be empty!"
        fi
    done

    Echo_Yellow "Enter more domain name(example: lnmp.org sub.lnmp.org): "
    read moredomain
    echo " domain list: ${domain} ${moredomain}"

    vhostdir="/home/wwwroot/${domain}"
    Echo_Yellow "Please enter the directory for the domain: $domain"
    echo
    Echo_Yellow "Default directory: /home/wwwroot/${domain}: "
    read vhostdir
    if [ "${vhostdir}" == "" ]; then
        vhostdir="/home/wwwroot/${domain}"
    fi
    echo "Virtual Host Directory: ${vhostdir}"

    Echo_Yellow "Allow Rewrite rule? (y/n) "
    read allow_rewrite
    if [[ "${allow_rewrite}" == "n" || "${allow_rewrite}" == "" ]]; then
        rewrite="none"
    elif [ "${allow_rewrite}" == "y" ]; then
        rewrite="other"
        echo "Please enter the rewrite of programme, "
        echo "wordpress,discuzx,typecho,thinkphp,laravel,codeigniter,yii2,zblog rewrite was exist."
        Echo_Yellow "(Default rewrite: other): "
        read rewrite
        if [ "${rewrite}" == "" ]; then
            rewrite="other"
        fi
    fi
    echo "You choose rewrite: ${rewrite}"

    Echo_Yellow "Enable PHP Pathinfo? (y/n) "
    read enable_pathinfo
    if [[ "${enable_pathinfo}" == "n" || "${enable_pathinfo}" == "" ]]; then
        echo "Disable pathinfo."
        enable_pathinfo="n"
    elif [ "${enable_pathinfo}" == "y" ]; then
        echo "Enable pathinfo."
        enable_pathinfo="y"
    fi

    Multiple_PHP_Select

    echo ""
    echo "Press any key to start create virtul host..."
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}

    echo "Create Virtul Host directory......"
    mkdir -p ${vhostdir}
    echo "set permissions of Virtual Host directory......"
    chmod -R 755 ${vhostdir}
    chown -R www:www ${vhostdir}

    Add_VHost_Config


    Echo_Green "================================================"
    echo "Virtualhost infomation:"
    echo "Your domain: ${domain}"
    echo "Home Directory: ${vhostdir}"
    echo "Rewrite: ${rewrite}"

    Echo_Green "================================================"
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo -n $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}