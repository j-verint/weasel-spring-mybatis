weasel-spring-mybatis
=====================
前言

这是一个基本Spring项目的mybatis的封装包。该包主要封装了对数据库的一些通用CURD操作和数据库的连接。项目基于mybatis-3.2.1

功能
一 通用CRUD数据库操作。通过MybatisRepository接口和MybatisOperations提供了一些通用的CURD数据库操作。
二 分页插件。能过PagePlugin提供自动分页，目前支持MySQL和PostgreSQL数据库的分页。如果需要更多的数据库支持，用户可以实现Dialect接口来实现。
三 合并mybatis配置文件。默认情况下，mybatis的配置文件只能有一个，所有mybatis的配置都需要配置在该配置文件下。但有些时候，我们需要在多个文件中配置mybatis。虽然这种情况很少见，但的确存在。可以通过提供的MyBatisSqlSessionFactoryBean代替org.mybatis.spring.SqlSessionFactoryBean。该功能处于测验性阶段。
四 读写分离。通过DynamicRWDataSourceProxy提供读写分离代理，适用于一个读库和一个写库的使用场景。
五 多数据源读写分离。通过DynamicMultiRWDataSourceProxy提供多数据源的读写分离代理，适用于多个读库和多个写库的使用场景。
六 读写分离插件。通过RWPlugin提供自动读写分离。
七 自定义读写库。用户可以通过DataSourceHolder自定义在执行sql语句前使用读库还是写库。如果用户想在读库中执行该语句，可以调用DataSourceHolder的静态方法useRead来切换。如果用户想在写库中执行该语句，可以调用DataSourceHolder的静态方法useWrite来切换。当用户通过DataSourceHolder指定了读写库，本次sql执行RWPlugin的自动路由将不起作用。

依赖包

要连接数据库，首先要将数据库厂商的连接实现依赖到项目中，在这个包中没有依赖该实现包，需要使用者在自己的应用中依赖。
mysql的依赖配置

<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<version>5.1.36</version>
</dependency>

postgresql的依赖配置
<dependency>
	<groupId>org.postgresql</groupId>
	<artifactId>postgresql</artifactId>
	<version>9.4-1202-jdbc42</version>
</dependency>


配置

一 分页插件配置
  在mybatis配置文件<plugins>节点下添加以下配置:
	<plugin interceptor="com.weasel.mybatis.PagePlugin">
		<property name="SQL_REGULAR" value=".*?queryPage.*?"/>
		<!-- <property name="DIALECT" value="com.weasel.mybatis.dialect.impl.MySQLDialect"/> -->
		<property name="DIALECT" value="com.weasel.mybatis.dialect.impl.PostgreSQLDialect"/>
	</plugin>

二 读写分离插件配置
    在mybatis配置文件<plugins>节点下添加以下配置:
    <plugin interceptor="com.melon.framework.mybatis.RWPlugin"/>

三 双数据源的读写分离配置
   在spring配置文件中先配置读数据和写数据源:
   <bean id="master" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${r.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${r.jdbc.url}" />
		<property name="user" value="${r.jdbc.username}" />
		<property name="password" value="${r.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
	<bean id="slave" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${w.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${w.jdbc.url}" />
		<property name="user" value="${w.jdbc.username}" />
		<property name="password" value="${w.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
   再在spring配置文件中定义数据源的代理类:
  <bean id="mySqlDataSource" class="com.concom.mybatis.DynamicRWDataSourceProxy">   
        <property name="readDataSource" ref="master"/>
        <property name="writeDataSource" ref="slave"/>
  </bean>
  在spring配置文件中定义SessionFactory:
  <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="mySqlDataSource" />
		<property name="configLocation" value="classpath:META-INF/mybatis/mybatis.xml" />
		<property name="mapperLocations" value="classpath:META-INF/mybatis/mappers/**/*.xml" />
	</bean>
四 多数据源读写分离配置
  在spring配置文件中先配置读数据和写数据源:
  <bean id="master1" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${r1.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${r1.jdbc.url}" />
		<property name="user" value="${r1.jdbc.username}" />
		<property name="password" value="${r1.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
	<bean id="master2" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${r2.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${r2.jdbc.url}" />
		<property name="user" value="${r2.jdbc.username}" />
		<property name="password" value="${r2.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
	<bean id="slave1" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${w1.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${w1.jdbc.url}" />
		<property name="user" value="${w1.jdbc.username}" />
		<property name="password" value="${w1.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
	<bean id="slave2" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<property name="driverClass" value="${w2.jdbc.dirverClass}" />
		<property name="jdbcUrl" value="${w2.jdbc.url}" />
		<property name="user" value="${w2.jdbc.username}" />
		<property name="password" value="${w2.jdbc.password}" />
		<property name="autoCommitOnClose" value="false" />
		<property name="initialPoolSize" value="10" />
		<property name="maxPoolSize" value="30" />
		<property name="minPoolSize" value="10" />
		<property name="maxIdleTime" value="1800" />
		<property name="maxStatements" value="1000" />
		<property name="idleConnectionTestPeriod" value="8" />
	</bean>
    再在spring配置文件中定义数据源的代理类:
    <bean id="mySqlDataSource" class="com.concom.mybatis.DynamicMultiRWDataSourceProxy">   
        <property name="readDataSources">
        	<list>
        		<ref bean="master1"/>
        		<ref bean="master2"/>
        	</list>
        </property>
        <property name="writeDataSources">
        	<list>
        		<ref bean="slave1"/>
        		<ref bean="slave2"/>
        	</list>
        </property>
    </bean>
   在spring配置文件中定义SessionFactory:
  <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="mySqlDataSource" />
		<property name="configLocation" value="classpath:META-INF/mybatis/mybatis.xml" />
		<property name="mapperLocations" value="classpath:META-INF/mybatis/mappers/**/*.xml" />
  </bean>	
  
  注意：在三和四中只需要配置一种场景就可以，理论上多数据源读写分离中读库和写库可以是任意多个。读写分离只是数据源的路由，并没有做到读库和写库的数据同步。要实现读库和写库的数据同步，用户需要自行在数据库级中处理。
  
五 mybatis多个配置文件合并配置。
  在spring配置文件中定义SessionFactory:
  <bean id="sqlSessionFactory" class="com.weasel.mybatis.MyBatisSqlSessionFactoryBean">
		<property name="dataSource" ref="mySqlDataSource" />
		<property name="configLocation" value="classpath:META-INF/mybatis/config/*.xml" />  <!--将所有mybatis配置文件放在config目录下。
		<property name="mapperLocations" value="classpath:META-INF/mybatis/mappers/**/*.xml" />
  </bean>

六 使用通用CURD。

  自定义一个接口，继承MybatisRepository。
 public interface UserRepository extends MybatisRepository<Long, User> {

}
  自定义一个类，继承MybatisOperations，并实现自定义的接口。
 public class UserRepositoryImpl extends MybatisOperations<Long, User> implements UserRepository {

}
 这样自定义的类就拥有了连接数据库和一些通用的CRUD操作，这些方法来自MybatisOperations，分别有get(ID id);save(T entity);saveBatch(List<T> entities);insert(T entity);update(T entity);delete(T entity); deleteBatch(List<T> entities);query(T entity); queryPage(Page<T> page);方法。
这里值得注意的是save方法，该方法的默认实现是当entity的id值不为空时，认为用户想做的是更新操作，会调用update方法。当entity的id值为空时，认为用户想做的是插入操作，会调用insert方法。

 mapper文件的配置

当然，具体的sql语句该包是不知道的，这个还需要用户自己去定义，sql语句的定义在mapper文件中，具体怎么写mapper文件用户可以参考mybatis的官方文档，下面给一个简单的:
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.weasel.mybatis.test.domain.User">  

	<resultMap id="userResultMap" type="User">
		<id property="id" column="id" />
		<result property="username" column="username" />
		<result property="password" column="password" />
	</resultMap>

	<select id="getById" resultType="User">
		select * from users where id =
		#{id}
	</select>

	<insert id="save" parameterType="User">
		insert into users
		(id,username,password)
		values (#{id},#{username},#{password})
	</insert>

	<update id="update">
		update users set
		username = #{username},
		password = #{password}
		where id = #{id}
	</update>

	<select id="queryPage" resultMap="userResultMap">
		select id as id,
			   username as username,
			   password as password
	    from users
	</select>

</mapper>

mapper文件配置的一些注意事项
这里我们看到namespace使用的是com.weasel.mybatis.test.domain.User，即用户类的包路径，这里是一个约定。如果用户不想这样的约定，在继承MybatisOperations类时可以重写getNamespace，自定义namespace。还有个queryPage，因为分页插件中配置了<property name="SQL_REGULAR" value=".*?queryPage.*?"/>，也即当发起带有queryPage字母的，插件都会拦截，为该请求加上分页，这也是一个约定。
因为MybatisOperations中提供了很多通用的方法，但这些方法的sql语句是都没有写的，框架也不知道用户具体的sql语句怎么写，需要用户自己提供。如果用户需要使用所有MybatisOperations提供的方法，应该在mapper文件中定义以下的sql语句，方法和对应的sql语句的id如下:

get(ID id) <---------> getById
get(T entity) <---------> get
insert(T entity) <---------> save
update(T entity) <---------> update
delete(T entity) <---------> delete
query(T entity) <---------> query
queryPage(Page<T> page) <---------> queryPage
