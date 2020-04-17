#include <boost/algorithm/string/classification.hpp> // Include boost::for is_any_of
#include <boost/algorithm/string/split.hpp> // Include for boost::split
#include <iostream>
#include <vector>
#include <fstream>
#include <unordered_map>
#include <unordered_set>
#include <ctype.h>
// #include "tinyexpr.h"




using namespace std;

unordered_map<string, float> IDs;
vector<string> res;

bool is_number(const std::string& s)
{
    std::string::const_iterator it = s.begin();
    while (it != s.end() && std::isdigit(*it)) ++it;
    return !s.empty() && it == s.end();
}

void variable_propogate(vector<string>& program, unordered_set<string>& ignore){
  vector<string> words;
  bool flag = 0;
  string expr = "";
  for(auto line: program){
      if(line != "" ){

        if(line.find(":") != std::string::npos){
          res.push_back(line);
        }
        else {
          flag = 0;
          expr = "";
          boost::split(words, line, boost::is_any_of(" "), boost::token_compress_on);
          if(ignore.find(words[0]) == ignore.end()){
            cout << words[1] << endl;
            if(words.size() > 1 && words[1] == "="){

              for(int i = 2; i < words.size(); i++){
                if(!is_number(words[i])){
                  if(IDs.find(words[i]) != IDs.end()){
                    words[i] = IDs[words[i]];
                    flag = 1;
                  }
                }
                expr += words[i];
              }
            }
            IDs[words[0]] = 2;
            res.push_back(words[0] + " = " + to_string(IDs[words[0]]));

        }
        }

      }
  }
}

// void find_for_loops(vector<string>& p)
int main(){
  ifstream in("./codeOpt/op.txt");
  unordered_set<string> ignore({"if", "goto"});
  if(!in.is_open()) throw std::runtime_error("Could not open file");
  std::string contents((std::istreambuf_iterator<char>(in)),
                          std::istreambuf_iterator<char>());

  vector<string> program;
  boost::split(program, contents, boost::is_any_of("\n"), boost::token_compress_on);
  cout << program.size();


  variable_propogate(program, ignore);

  for(auto line: res){
    cout << line << endl;
  }
}
