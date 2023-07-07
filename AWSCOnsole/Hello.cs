using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AWSCOnsole
{
  public class Hello
    {
        public string GetName()
        {
            string name = "Hello World";
            Console.WriteLine(name); 
            return name;    
        }
        //static void Main(string[] args)
        //{
        //    Hello hello = new Hello();
        //    hello.GetName();
        }
}
