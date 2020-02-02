import flare/twilio-7.9.1-alpha-1-jar-with-dependencies.jar;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;

public class Sms{
    // Find your Account Sid and Token at twilio.com/user/account
    static final String ACCOUNT_SID = "ACf864fd035298230645b6fab4a205ca0b";
    static final String AUTH_TOKEN = "bf7f67cf71991ee7ed0157fbf0f74783";
    static int code;
    static String msg;
    static String default_msg = "come help me. This is my location:";

    void sms() {
        Twilio.init(ACCOUNT_SID, AUTH_TOKEN);
        //TODO add code number depending on button activated
        if(code == 1) {
            msg = "I just had a stroke, " + default_msg;
        }
        else if(code ==2 ) {
            msg = "I am injured, " + default_msg;
        }

        Message message = Message.creator(
                //To
                new PhoneNumber("+15147466682"),
                //From
                new PhoneNumber("+12024100780"),

                msg
        ).create();

        System.out.println(message.getSid());
    }
}