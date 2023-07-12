public with sharing class ChatGPTService extends ZD_VirtualCallable {
    
    public override Object doCall(String action, Map<String,Object> args){
        switch on action {
            when 'docallout' {
                String prompt = String.valueOf(args.get('prompt'));
                return this.doCallout(prompt);
            }
        }
        return null;
    }

    private String doCallout(String prompt){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:chatGPTKey');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        request.setTimeout(40000);
        String requestBody = '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "' + prompt + '"}], "max_tokens": 2000 }';
        request.setBody(requestBody);
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                String responseJson = response.getBody();
                //Parse the JSON response
                Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(responseJson);
                // Extract the 'choices' array from the response data
                List<Object> choices = (List<Object>)responseData.get('choices');
                // Extract the first choice (assuming there's at least one choice)
                Map<String, Object> firstChoice = (Map<String, Object>)choices[0];
                Map<String, Object> message = (Map<String, Object>)firstChoice.get('message');
                // Extract the 'text' property from the first choice
                String content = (String)message.get('content');
                // Print the extracted content
                System.debug('Content: ' + content);
                return content;
            } else {
                System.debug('ChatGPT API call failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception ex) {
            System.debug('An error occurred while making the ChatGPT API call: ' + ex.getMessage());
        }
        return 'No auto generated response available (You may need an API key)';
    }
}